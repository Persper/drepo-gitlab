require 'spec_helper'

describe SendFileUpload do
  let(:uploader_class) do
    Class.new(GitlabUploader) do
      include ObjectStorage::Concern

      storage_options Gitlab.config.uploads

      private

      # user/:id
      def dynamic_segment
        File.join(model.class.to_s.underscore, model.id.to_s)
      end
    end
  end

  let(:controller_class) do
    Class.new do
      include SendFileUpload
    end
  end

  let(:object) { build_stubbed(:user) }
  let(:uploader) { uploader_class.new(object, :file) }

  describe '#send_upload' do
    let(:controller) { controller_class.new }
    let(:temp_file) { Tempfile.new('test') }
    let(:params) { {} }

    subject { controller.send_upload(uploader, **params) }

    before do
      FileUtils.touch(temp_file)
    end

    after do
      FileUtils.rm_f(temp_file)
    end

    context 'when local file is used' do
      before do
        uploader.store!(temp_file)
      end

      it 'sends a file' do
        expect(controller).to receive(:send_file).with(uploader.path, anything)

        subject
      end
    end

    context 'with attachment' do
      let(:file) { 'image.png' }
      let(:send_attachment) { controller.send_upload(uploader, attachment: file) }

      shared_examples 'send attachments' do
        let(:send_attachment) { controller.send_upload(uploader, attachment: file) }

        context 'when feature flag workhorse_set_content_type is' do
          before do
            stub_feature_flags(workhorse_set_content_type: flag_value)

            expect(controller).to receive(:send_file).with(uploader.path, expected_params)
          end

          context 'enabled' do
            let(:flag_value) { true }
            let(:expected_params) { expected_feature_enabled_params }

            it 'sends a file with content-type of text/plain' do
              send_attachment
            end
          end

          context 'disabled' do
            let(:flag_value) { false }
            let(:expected_params) { expected_feature_disabled_params }

            it 'sends a file with content-type of text/plain' do
              send_attachment
            end
          end
        end
      end

      it_behaves_like 'send attachments' do
        let(:expected_feature_enabled_params) do
          {
            filename: 'image.png'
          }
        end
        let(:expected_feature_disabled_params) do
          {
            filename: 'image.png',
            disposition: 'attachment'
          }
        end
      end

      context 'when file format is javascript' do
        let(:file) { 'test.js' }

        it_behaves_like 'send attachments' do
          let(:expected_feature_enabled_params) do
            {
              content_type: 'text/plain',
              filename: 'test.js'
            }
          end
          let(:expected_feature_disabled_params) do
            {
              content_type: 'text/plain',
              filename: 'test.js',
              disposition: 'attachment'
            }
          end
        end

        context 'with a proxied file in object storage' do
          before do
            stub_uploads_object_storage(uploader: uploader_class)
            uploader.object_store = ObjectStorage::Store::REMOTE
            uploader.store!(temp_file)
            allow(Gitlab.config.uploads.object_store).to receive(:proxy_download) { true }
          end

          context 'when feature flag workhorse_set_content_type is' do
            let(:headers) { double }

            before do
              stub_feature_flags(workhorse_set_content_type: flag_value)

              expect(headers).to receive(:store).with(Gitlab::Workhorse::SEND_DATA_HEADER, /^send-url:/)
              expect(controller).not_to receive(:send_file)
              expect(controller).to receive(:headers) { headers }
              expect(controller).to receive(:head).with(:ok)
            end

            context 'enabled' do
              let(:flag_value) { true }

              it 'sends a file without response custom type params' do
                expect(Gitlab::Workhorse).not_to receive(:send_url).with(/response-content-disposition/)
                expect(Gitlab::Workhorse).not_to receive(:send_url).with(/response-content-type/)
                expect(Gitlab::Workhorse).to receive(:send_url).and_call_original

                send_attachment
              end
            end

            context 'disabled' do
              let(:flag_value) { false }
              let(:expected_headers) { %r(response-content-disposition=attachment%3Bfilename%3D%22test.js%22&response-content-type=text/plain) }

              it 'sends a file with a custom type' do
                expect(Gitlab::Workhorse).to receive(:send_url).with(expected_headers).and_call_original

                send_attachment
              end
            end
          end
        end
      end
    end

    context 'when remote file is used' do
      before do
        stub_uploads_object_storage(uploader: uploader_class)
        uploader.object_store = ObjectStorage::Store::REMOTE
        uploader.store!(temp_file)
      end

      shared_examples 'proxied file' do
        it 'sends a file' do
          headers = double
          expect(Gitlab::Workhorse).not_to receive(:send_url).with(/response-content-disposition/)
          expect(Gitlab::Workhorse).not_to receive(:send_url).with(/response-content-type/)
          expect(Gitlab::Workhorse).to receive(:send_url).and_call_original

          expect(headers).to receive(:store).with(Gitlab::Workhorse::SEND_DATA_HEADER, /^send-url:/)
          expect(controller).not_to receive(:send_file)
          expect(controller).to receive(:headers) { headers }
          expect(controller).to receive(:head).with(:ok)

          subject
        end
      end

      context 'and proxying is enabled' do
        before do
          allow(Gitlab.config.uploads.object_store).to receive(:proxy_download) { true }
        end

        it_behaves_like 'proxied file'
      end

      context 'and proxying is disabled' do
        before do
          allow(Gitlab.config.uploads.object_store).to receive(:proxy_download) { false }
        end

        it 'sends a file' do
          expect(controller).to receive(:redirect_to).with(/#{uploader.path}/)

          subject
        end

        context 'with proxy requested' do
          let(:params) { { proxy: true } }

          it_behaves_like 'proxied file'
        end
      end
    end
  end
end

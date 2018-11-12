# frozen_string_literal: true

# Shared examples for controllers that load and send files from the git repository
# (like Projects::RawController or Projects::AvatarsController)

# These examples requires the following variables:
# - `project`
# - `filename`: filename of the file
# - `filepath`: path of the file (contains filename)
# - `subject`: the request to be made to the controller. Example:
# subject { get :show, namespace_id: project.namespace, project_id: project }
shared_examples 'repository lfs file load' do
  context 'when file is stored in lfs' do
    let(:lfs_oid) { '91eff75a492a3ed0dfcb544d7f31326bc4014c8551849c192fd1e48d4dd2c897' }
    let(:lfs_size) { '1575078' }
    let!(:lfs_object) { create(:lfs_object, oid: lfs_oid, size: lfs_size) }

    context 'when lfs is enabled' do
      before do
        allow_any_instance_of(Project).to receive(:lfs_enabled?).and_return(true)
      end

      context 'when project has access' do
        before do
          project.lfs_objects << lfs_object
          allow_any_instance_of(LfsObjectUploader).to receive(:exists?).and_return(true)
          allow(controller).to receive(:send_file) { controller.head :ok }
        end

        context 'when feature flag workhorse_set_content_type is' do
          before do
            stub_feature_flags(workhorse_set_content_type: flag_value)
          end

          context 'enabled' do
            let(:flag_value) { true }

            it 'serves the file' do
              expect(controller).to receive(:send_file).with("#{LfsObjectUploader.root}/91/ef/f75a492a3ed0dfcb544d7f31326bc4014c8551849c192fd1e48d4dd2c897", filename: filename)

              subject

              expect(response).to have_gitlab_http_status(200)
            end
          end

          context 'disabled' do
            let(:flag_value) { false }

            it 'serves the file' do
              expect(controller).to receive(:send_file).with("#{LfsObjectUploader.root}/91/ef/f75a492a3ed0dfcb544d7f31326bc4014c8551849c192fd1e48d4dd2c897", filename: filename, disposition: 'attachment')

              subject

              expect(response).to have_gitlab_http_status(200)
            end
          end
        end

        context 'and lfs uses object storage' do
          let(:lfs_object) { create(:lfs_object, :with_file, oid: lfs_oid, size: lfs_size) }

          before do
            stub_lfs_object_storage
            lfs_object.file.migrate!(LfsObjectUploader::Store::REMOTE)
          end

          it 'responds with redirect to file' do
            subject

            expect(response).to have_gitlab_http_status(302)
            expect(response.location).to include(lfs_object.reload.file.path)
          end

          context 'when feature flag workhorse_set_content_type is' do
            before do
              stub_feature_flags(workhorse_set_content_type: flag_value)
            end

            context 'enabled' do
              let(:flag_value) { true }

              it 'sets content disposition' do
                subject

                file_uri = URI.parse(response.location)
                params = CGI.parse(file_uri.query)

                expect(params).not_to include('response-content-disposition', 'response-content-type')
              end
            end

            context 'disabled' do
              let(:flag_value) { false }

              it 'sets content disposition' do
                subject

                file_uri = URI.parse(response.location)
                params = CGI.parse(file_uri.query)

                expect(params["response-content-disposition"].first).to eq "attachment;filename=\"#{filename}\""
              end
            end
          end
        end
      end

      context 'when project does not have access' do
        it 'does not serve the file' do
          subject

          expect(response).to have_gitlab_http_status(404)
        end
      end
    end

    context 'when lfs is not enabled' do
      before do
        allow_any_instance_of(Project).to receive(:lfs_enabled?).and_return(false)
      end

      context 'when feature flag workhorse_set_content_type is' do
        before do
          stub_feature_flags(workhorse_set_content_type: flag_value)
        end

        context 'enabled' do
          let(:flag_value) { true }

          it 'delivers ASCII file' do
            subject

            expect(response).to have_gitlab_http_status(200)
            expect(response.header['Content-Type']).to eq('text/plain; charset=utf-8')
            expect(response.header['Content-Disposition']).to be_nil
            expect(response.header[Gitlab::Workhorse::SEND_DATA_HEADER]).to start_with('git-blob:')
          end
        end

        context 'disabled' do
          let(:flag_value) { false }

          it 'delivers ASCII file' do
            subject

            expect(response).to have_gitlab_http_status(200)
            expect(response.header['Content-Type']).to eq('text/plain; charset=utf-8')
            expect(response.header['Content-Disposition']).to eq('inline')
            expect(response.header[Gitlab::Workhorse::SEND_DATA_HEADER]).to start_with('git-blob:')
          end
        end
      end
    end
  end
end

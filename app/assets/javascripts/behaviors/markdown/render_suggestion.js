// Renders code suggestions
// `js-render-suggestion` class.
//
// Example markup:
//
// ```suggestion
//  <p>I suggestion we change it to this</p>
// ```

function applySuggestion() {
  // TODO dispatch > api call
}

export default function renderSuggestion($els) {
  if (!$els.length) return;

  $els.each((i, el) => {

    const applyBtn = document.createElement('button');
    const fileHeader = document.createElement('div');
    const comment = document.createTextNode(el.dataset.comment);

    applyBtn.onclick = ()=> applySuggestion();
    applyBtn.classList.add('btn');
    applyBtn.innerText = 'Apply';

    fileHeader.classList.add('file-title-flex-parent', 'suggestion-note-header', 'mt-2', 'border-bottom-0');
    fileHeader.innerText = el.dataset.file;
    fileHeader.appendChild(applyBtn);

    el.parentNode.insertBefore(comment, el);
    el.parentNode.insertBefore(fileHeader, el);
  });
}

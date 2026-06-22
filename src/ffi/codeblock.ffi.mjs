// arata — code-block FFI: injects a copy button and language label into each
// `pre > code` block, mirroring apollo's `static/js/codeblock.js`.
//
// Because the post body is rendered via `unsafe_raw_html`, the `<pre><code>`
// blocks are already in the DOM but without the fancy buttons. This function
// post-processes them: for each `pre > code`, it reads the `data-lang`
// attribute (defaulting to "default"), creates a `.clipboard-button` and a
// `.code-label.label-<lang>`, appends them to the `<pre>`, and wires the copy
// handler.
//
// The copy handler calls `navigator.clipboard.writeText` with the code text
// (stripping `.giallo-ln` line-number spans first), then swaps the button icon
// to a check (success) or × (error) for 2 seconds before reverting.

const copyIcon = `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16"><path d="M10 1.5a.5.5 0 0 1 .5-.5h2a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-9a2 2 0 0 1-2-2V3a2 2 0 0 1 2-2h2a.5.5 0 0 1 .5.5V3h3V1.5zM6.5 3V2h3v1h-3zm4 0v1h2a1 1 0 0 0-1-1h-2V3zm-5 0H3a1 1 0 0 0-1 1v11a1 1 0 0 0 1 1h9a1 1 0 0 0 1-1V4a1 1 0 0 0-1-1H5.5V3z"/></svg>`;
const successIcon = `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16"><path d="M13.485 1.85a.5.5 0 0 1 1.065.02.75.75 0 0 1-.02 1.065L5.82 12.78a.75.75 0 0 1-1.106.02L1.476 9.346a.75.75 0 1 1 1.05-1.07l2.74 2.742L12.44 2.92a.75.75 0 0 1 1.045-.07z"/></svg>`;
const errorIcon = `<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 16 16"><path d="M2.293 2.293a1 1 0 0 1 1.414 0L8 6.586l4.293-4.293a1 1 0 0 1 1.414 1.414L9.414 8l4.293 4.293a1 1 0 0 1-1.414 1.414L8 9.414l-4.293 4.293a1 1 0 0 1-1.414-1.414L6.586 8 2.293 3.707a1 1 0 0 1 0-1.414z"/></svg>`;

export function enhance_code_blocks() {
  const blocks = document.querySelectorAll("pre code");
  blocks.forEach((codeBlock) => {
    const pre = codeBlock.parentNode;
    if (!pre || pre.querySelector(".clipboard-button")) return; // skip if already enhanced

    pre.style.position = "relative";

    // Copy button
    const copyBtn = document.createElement("button");
    copyBtn.className = "clipboard-button";
    copyBtn.innerHTML = copyIcon;
    copyBtn.setAttribute("aria-label", "Copy code to clipboard");
    copyBtn.addEventListener("click", async () => {
      const codeToCopy = getCodeText(codeBlock);
      try {
        await navigator.clipboard.writeText(codeToCopy);
        changeIcon(copyBtn, true);
      } catch {
        changeIcon(copyBtn, false);
      }
    });
    pre.appendChild(copyBtn);

    // Language label
    const lang = codeBlock.getAttribute("data-lang") || "default";
    const label = document.createElement("span");
    label.className = "code-label label-" + lang;
    label.textContent = lang.toUpperCase();
    pre.appendChild(label);

    // Keep button + label pinned on horizontal scroll
    let ticking = false;
    pre.addEventListener("scroll", () => {
      if (!ticking) {
        window.requestAnimationFrame(() => {
          copyBtn.style.right = `-${pre.scrollLeft}px`;
          label.style.right = `-${pre.scrollLeft}px`;
          ticking = false;
        });
        ticking = true;
      }
    });
  });
}

function getCodeText(codeBlock) {
  const clone = codeBlock.cloneNode(true);
  clone.querySelectorAll(".giallo-ln").forEach((el) => el.remove());
  return clone.textContent.trim();
}

function changeIcon(button, isSuccess) {
  button.innerHTML = isSuccess ? successIcon : errorIcon;
  setTimeout(() => {
    button.innerHTML = copyIcon;
  }, 2000);
}

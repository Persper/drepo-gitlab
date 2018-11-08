export default function scrollIntoViewPromise(intersectionTarget) {
  return new Promise(resolve => {
    const intersectionObserver = new IntersectionObserver(entries => {
      if (entries[0].isIntersecting) resolve();
    });

    intersectionObserver.observe(intersectionTarget);

    intersectionTarget.scrollIntoView();
  });
}

const TRANSITION_MS = 350;

function matchesFilter(item, filter) {
    return filter === 'all' || item.dataset.filter === filter;
}

function showItem(item) {
    item.style.display = '';
    // Force reflow so the transition fires
    item.classList.add('is-entering');
    requestAnimationFrame(() => {
        requestAnimationFrame(() => {
            item.classList.remove('is-entering');
        });
    });
}

function hideItem(item, onDone) {
    item.classList.add('is-hiding');
    setTimeout(() => {
        item.classList.remove('is-hiding');
        item.style.display = 'none';
        if (onDone) onDone();
    }, TRANSITION_MS);
}

function initIsotopeFilters() {
    const filterNav = document.getElementById('isotope-filters');
    const grid = document.getElementById('isotope-grid');
    if (!filterNav || !grid) return;

    const filterBtns = Array.from(filterNav.querySelectorAll('.filter-btn'));
    const items = Array.from(grid.querySelectorAll('.isotope-item'));
    let currentFilter = 'all';
    let animating = false;

    filterBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            const filter = btn.dataset.filter;
            if (filter === currentFilter || animating) return;

            animating = true;
            currentFilter = filter;

            // Update active button
            filterBtns.forEach(b => b.classList.toggle('active', b === btn));

            const toHide = items.filter(item => !matchesFilter(item, filter));
            const toShow = items.filter(item =>
                matchesFilter(item, filter) && item.style.display === 'none'
            );

            let pending = toHide.length;

            if (pending === 0) {
                // Nothing to hide — just show new items and unlock
                toShow.forEach(showItem);
                animating = false;
                return;
            }

            toHide.forEach(item => {
                hideItem(item, () => {
                    pending--;
                    if (pending === 0) {
                        toShow.forEach(showItem);
                        animating = false;
                    }
                });
            });
        });
    });
}

window.addEventListener('load', () => {
    initIsotopeFilters();
});

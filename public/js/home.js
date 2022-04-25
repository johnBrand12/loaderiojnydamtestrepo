const headerSearchContainer = document.querySelector('.hme-header-search-container');

const redirectToExplorePage = () => {

    window.location.href = "/search";
}


headerSearchContainer.addEventListener('click', redirectToExplorePage);
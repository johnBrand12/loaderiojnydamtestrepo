
const exploreSearchButton = document.querySelector('.expl-search-button');
const exploreSearchInput = document.querySelector('.expl-second-row-searchinput');

console.log("This is the search button");
console.log(exploreSearchButton);

exploreSearchButton.addEventListener('click', () => {

    console.log("Looks like you clicked the search button!");

    console.log("This is the value");
    console.log(exploreSearchInput.value);

    console.log("Hopefully this will work!");

    window.location.href = `/search/${exploreSearchInput.value}`;

    // fetch(`http://localhost:4567/search/${exploreSearchInput.value}`)
    // .then((res) => {

    //     console.log("successful stuff")
    //     console.log(res.status);
    //     console.log(res.data);
    // })
    // .catch((err) => {
    //     console.log("Something went wrong");
    //     console.log(err);
    // })
});








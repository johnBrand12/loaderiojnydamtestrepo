
const friendSearchInput = document.querySelector('.ppl-search-friends-input');
const friendSearchButton = document.querySelector('.ppl-search-friends-button');

const userListResultContainer = document.querySelector('.ppl-search-component-container');

const followButton = document.querySelector('.ppl-follow');
const unfollowButton = document.querySelector('.ppl-unfollow');

friendSearchButton.addEventListener('click', async () => {

    const user = friendSearchInput.value;

    console.log("You pressed the search button!");


    let followingListCacheList = await fetch(`http://localhost:4567/following/retrievelistcache?uid=67`)

    let followingListCacheListJson = await followingListCacheList.json();

    console.log("We have first received the following cache list");
    console.log("Attache dis the following cache list");

    console.log(followingListCacheListJson);

    fetch(`http://localhost:4567/search/friends/${user}`)
    .then((res) => res.json())
    .then((res) => {

        console.log("Successful response was returned");
        console.log(res);

        let resultStringList = "";

        [...res].forEach((element) => {


            let elem = followingListCacheListJson.filter((iterative) => iterative.star_displayname === element.display_name)

            if (elem.length != 0) {
                
            }

            let newSearchResultComp = `<div class="ppl-search-result-component" id=${element.id}>
                    <div class="ppl-image-container">
                        <img class="ppl-twitterlogo" src="twitterlogo.png"/>
                    </div>
                    <div class="ppl-friend-name-container">
                        <span>${element.display_name}</span>
                    </div>
                    <div class="ppl-button-container">
                        <button class="ppl-follow-button-type ppl-follow">Follow</button>
                        <button disabled class="ppl-follow-button-type ppl-unfollow">Unfollow</button>
                    </div>
                </div>`;

            resultStringList += newSearchResultComp;

        });

        userListResultContainer.innerHTML = resultStringList;

        Array.from(document.getElementsByClassName('ppl-follow')).forEach((elem)=>{

            elem.addEventListener('click',(e)=>{


                console.log("You just pressed the follow button!");
                console.log("And this is the event information");

                const localUserId = e.target.parentNode.parentNode.getAttribute('id');

                const localUserDisplayName = e.target.parentNode.parentNode.querySelector('.ppl-friend-name-container').textContent.trim();

                console.log(localUserDisplayName);
                console.log(localUserId);

                const options = {
                    method: 'POST',
                    body: JSON.stringify({
                        star_id: localUserId
                    })
                };

                fetch('http://localhost:4567/insertfollowingservice', options)
                .then((res) => res.json())
                .then((res) => {

                    console.log("we got to the insert following resolution");
                    console.log(res);

                    console.log("We need to perform an operation on the below button");
                    console.dir(e.target);

                    e.target.className += " ppl-follow-black-white"
                    e.target.innerHTML = "Followed";
                    e.target.disabled = true;

                    const adjacentUnFollowButton = e.target.parentNode.querySelector('.ppl-unfollow');

                    adjacentUnFollowButton.disabled = false;
                })
                .catch((err) => {

                    console.log("There was an error inserting the follow relationship.")
                })
            });

        });

        Array.from(document.getElementsByClassName('ppl-unfollow')).forEach((elem)=>{

            elem.addEventListener('click',(e)=>{

                console.log("You just pressed the unfollow button!");
                console.log("And this is the event information");

                const localUserDisplayName = e.target.parentNode.parentNode.querySelector('.ppl-friend-name-container').textContent.trim();

                console.log(localUserDisplayName);
            });

        });

    })
    .catch((err) => {

        console.log("There was an error");
        console.log(err);
    })
});

followButton.addEventListener('click', () => {

    console.log("Looks like you pressed the follow button!");

});


unfollowButton.addEventListener('click', () => {
    console.log("Looks like you pressed the unfollow button!");
});



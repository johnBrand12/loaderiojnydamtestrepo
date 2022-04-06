
const friendSearchInput = document.querySelector('.ppl-search-friends-input');
const friendSearchButton = document.querySelector('.ppl-search-friends-button');

const userListResultContainer = document.querySelector('.ppl-search-component-container');

const followButton = document.querySelector('.ppl-follow');
const unfollowButton = document.querySelector('.ppl-unfollow');

friendSearchButton.addEventListener('click', async () => {

    const user = friendSearchInput.value;

    let followingListCacheList = await fetch(`http://localhost:4567/following/retrievelistcache?uid=67`)

    let followingListCacheListJson = await followingListCacheList.json();

    fetch(`http://localhost:4567/search/friends/${user}`)
    .then((res) => res.json())
    .then((res) => {

        console.log("Successful response was returned");
        console.log(res);

        let resultStringList = "";

        [...res].forEach((element) => {


            let elem = followingListCacheListJson.filter((iterative) => {

                console.log("This is the iterative object");
                console.log(iterative);

                return iterative.star_displayname === element.display_name;

            });

            let dynamicFollowButtonClass;
            let dynamicFollowButtonText;
            let dynamicUnFollowButtonDisabledFlag;
            let dynamicFollowButtonDisabledFlag;

            if (elem.length != 0) {

                dynamicFollowButtonClass = "ppl-follow-button-type ppl-follow ppl-follow-black-white";
                dynamicFollowButtonText = "Followed";
                dynamicUnFollowButtonDisabledFlag = "";
                dynamicFollowButtonDisabledFlag = "disabled";

            } else {

                dynamicFollowButtonClass = "ppl-follow-button-type ppl-follow";
                dynamicFollowButtonText = "Follow";
                dynamicUnFollowButtonDisabledFlag = "disabled";
                dynamicFollowButtonDisabledFlag = "";

            }

            let newSearchResultComp = `<div class="ppl-search-result-component" id=${element.id}>
                    <div class="ppl-image-container">
                        <img class="ppl-twitterlogo" src="twitterlogo.png"/>
                    </div>
                    <div class="ppl-friend-name-container">
                        <span>${element.display_name}</span>
                    </div>
                    <div class="ppl-button-container">
                        <button ${dynamicFollowButtonDisabledFlag} class="${dynamicFollowButtonClass}">${dynamicFollowButtonText}</button>
                        <button ${dynamicUnFollowButtonDisabledFlag} class="ppl-follow-button-type ppl-unfollow">Unfollow</button>
                    </div>
                </div>`;

            resultStringList += newSearchResultComp;

        });

        userListResultContainer.innerHTML = resultStringList;

        Array.from(document.getElementsByClassName('ppl-follow')).forEach((elem)=>{

            elem.addEventListener('click',(e)=>{

                const localUserId = e.target.parentNode.parentNode.getAttribute('id');

                const localUserDisplayName = e.target.parentNode.parentNode.querySelector('.ppl-friend-name-container').textContent.trim();

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

                const localUserDisplayName = e.target.parentNode.parentNode.querySelector('.ppl-friend-name-container').textContent.trim();

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



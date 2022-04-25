const unfollowButtons = document.getElementsByClassName("fllwing-unfollow-button");

Array.from(unfollowButtons).forEach((buttonElem) => {

    buttonElem.addEventListener('click', (e) => {

        const buttonId = e.target.id;
        const clientUserId = e.target.getAttribute('clientid');
        const userAction = "unfollow";

        const options = {
            method: 'POST'
        };

        fetch(`/updatefollowings/${clientUserId}/${buttonId}/${userAction}`, options)
        .then((res) => {
            console.log("User was unfollowed");
            console.log(res);
            window.location.href = `/following?uid=${clientUserId}`;

        })
        .catch((err) => {
            console.log("There was an issue unfollowing the user");
            console.log(err);
        })

    });
})
const unfollowButtons = document.getElementsByClassName("fllwing-unfollow-button");

console.log(unfollowButtons);

Array.from(unfollowButtons).forEach((buttonElem) => {

    buttonElem.addEventListener('click', (e) => {

        console.log("You pressed the unfollow button!");

        const buttonId = e.target.id;

        const clientUserId = e.target.getAttribute('clientid');

        const userAction = "unfollow";

        console.log(buttonId);
        console.log(clientUserId);

        const options = {
            method: 'POST'
        };

        console.log(`http://localhost:4567/updatefollowings/${clientUserId}/${buttonId}/${userAction}`);

        fetch(`http://localhost:4567/updatefollowings/${clientUserId}/${buttonId}/${userAction}`, options)
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
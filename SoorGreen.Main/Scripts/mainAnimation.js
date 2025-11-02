// Scripts/mainAnimation.js
document.addEventListener("DOMContentLoaded", () => {
    lottie.loadAnimation({
        container: document.getElementById("animationContainer"),
        renderer: "svg",
        loop: false,
        autoplay: true,
        path: "Assets/animation.json" // Replace with your JSON animation
    });
});

$(document).ready(function () {

    videojs.autoSetup();

    videojs('display-video').ready(function () {
        console.log(this.options()); //log all of the default videojs options

        // Store the video object
        var myPlayer = this, id = myPlayer.id();
        // Make up an aspect ratio
        var aspectRatio = 480 / 640;

        function resizeVideoJS() {
            var width = document.getElementById(id).parentElement.offsetWidth;
            myPlayer.width(width).height(width * aspectRatio);
        }

        // Initialize resizeVideoJS()
        resizeVideoJS();
        // Then on resize call resizeVideoJS()
        window.onresize = resizeVideoJS;
        setVideoPlayerStyle(gon.player_primary_color, gon.player_secondary_color);
    });

});
var nav = document.getElementById('navbar');

document.onscroll = function() {
    nav.classList[ document.body.scrollTop < 77 ? 'remove' : 'add']('navbar--shadow');
};
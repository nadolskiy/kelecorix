$(".nav a").on("click", function(){
   $(".nav").find(".active").removeClass("active");
   $(this).parent().addClass("active");
});

function tocScroller() {
	window.addEventListener("scroll", function(event) {
	    var scroll_position = window.scrollY;
	    var distanceY = window.pageYOffset || document.documentElement.scrollTop;
	    var shrinkOn = 345;
	    var toc = document.getElementById("table-of-contents");

	    if (distanceY > shrinkOn) {
		if (!classie.has(toc, "smaller")) {
		    classie.add(toc, "sticky");
		    classie.add(toc, "smaller");
		}
	    } else {
		if (classie.has(toc, "smaller")) {
		    classie.remove(toc, "sticky");
		    classie.remove(toc, "smaller");
		}
	    }
	});
}

function buttonUp() {

    scrollTo = function(element, to, duration) {
	if (duration < 0) return;
	var difference = to - element.scrollTop,
	    perTick = difference / duration * 10;
	setTimeout(function() {
	    element.scrollTop = element.scrollTop + perTick;
	    if (element.scrollTop === to) return;
	    scrollTo(element, to, duration - 10);
	}, 10);
    };

    var btn = document.getElementById("stw");

    document.addEventListener('scroll', function() {
	var distanceY = window.pageYOffset || document.documentElement.scrollTop;
	if (distanceY > 350){
            classie.add(btn, "show");
	} else {
	    classie.remove(btn, "show");
	}
    });

    btn.addEventListener('click', function(e) {
      scrollTo(document.body, 50, 300)
    });
}

function init() {
    tocScroller();
    buttonUp();
}

//
$(document).ready(function(){
    var enImgLink = "../img/en.png";
    var ruImgLink = "../img/ru.png";
    var uaImgLink = "../img/ua.png";

    var imgBtnSel = $('#imgBtnSel');
    var imgBtnEn  = $('#imgBtnEn');
    var imgBtnRu  = $('#imgBtnRu');
    var imgBtnUa  = $('#imgBtnUa');

    var imgNavSel = $('#imgNavSel');
    var imgNavEn  = $('#imgNavEn');
    var imgNavRu  = $('#imgNavRu');
    var imgNavUa  = $('#imgNavUa');

    var spanNavSel = $('#lanNavSel');
    var spanBtnSel = $('#lanBtnSel');

    imgBtnSel.attr("src",enImgLink);
    imgBtnEn.attr("src",enImgLink);
    imgBtnRu.attr("src",ruImgLink);
    imgBtnUa.attr("src",uaImgLink);

    imgNavSel.attr("src",enImgLink);
    imgNavEn.attr("src",enImgLink);
    imgNavRu.attr("src",ruImgLink);
    imgNavUa.attr("src",uaImgLink);

    $( ".language" ).on( "click", function( event ) {
	var currentId = $(this).attr('id');

	if(currentId == "navEn") {
	    imgNavSel.attr("src",enImgLink);
	    spanNavSel.text("EN");
	} else if (currentId == "navRu") {
	    imgNavSel.attr("src",ruImgLink);
	    spanNavSel.text("RU");
	} else if (currentId == "navUa") {
	    imgNavSel.attr("src",uaImgLink);
	    spanNavSel.text("UA");
	}

	if(currentId == "btnEn") {
	    imgBtnSel.attr("src",enImgLink);
	    spanBtnSel.text("EN");
	} else if (currentId == "btnRu") {
	    imgBtnSel.attr("src",ruImgLink);
	    spanBtnSel.text("RU");
	} else if (currentId == "btnUa") {
	    imgBtnSel.attr("src",uaImgLink);
	    spanBtnSel.text("UA");
	}

    });
});

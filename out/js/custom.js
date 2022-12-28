/*  -----------------------------------------
    List Github repos
*/
var getGithub = function () {
	$.ajax({
		url: 'https://api.github.com/users/kelecorix/repos',
		dataType: 'json',
		success: function (data, status) {
			var html = "<ul class='list-group' style='list-style-type:none;margin-left:0;padding-left:0'>";
			for (i = 0; i < data.length; i++) {
				if (data[i].stargazers_count + data[i].forks > 1) {
					html += "<li class='list-group-item'><h3><a href='http://github.com/kelecorix/" + data[i].name;
					html += "' >" + data[i].name + "</a></h3> <span class='badge'>";
					html += " <i class='fa fa-star fa-lg'></i> " + data[i].stargazers_count + ' stars</span>';

					/*html += " <i class='glyphicon glyphicon-eye-open'></i> " + data[i].watchers_count + " watchers ";*/
					html += "<span class='badge'><i class='fa fa-code-fork fa-lg'></i> " + data[i].forks + ' forks </span>';
					html += '<span>' + data[i].description + '</span></li>';
				}
			} //end for
			html += '</ul>';
			$('#github-projects').append(html);
			x;
		} //endsuccess
	});
};

// function init() {
//   window.addEventListener('scroll', function(e) {
//     var distanceY = window.pageYOffset || document.documentElement.scrollTop,
//       shrinkOn = 150,
//       header = document.querySelector("header"),
//       nav = document.querySelector("nav"),
//       navbarHeader = document.getElementsByClassName('navbar-header')[0],
//       navbarNav = document.getElementsByClassName('navbar-nav')[0],
//       logo = document.getElementById('logo'),
//       navbarBrand = document.getElementsByClassName('navbar-brand');

//     if (distanceY > shrinkOn) {
//       classie.add(logo, "smaller");
//       classie.add(header, "smallerh");
//       classie.add(nav, "smaller");
//       for (var i = 0; i < navbarBrand.length; i++) {
//         classie.add(navbarBrand[i], "smaller");
//       }
//       classie.add(navbarHeader, "smaller");
//       classie.add(navbarNav, "smaller");
//     } else {
//       if (classie.has(header, "smallerh")) {
//         classie.remove(navbarNav, "smaller");
//         classie.remove(navbarHeader, "smaller");
//         for (var i = 0; i < navbarBrand.length; i++) {
//           classie.remove(navbarBrand[i], "smaller");
//         }
//         classie.remove(logo, "smaller");
//         classie.remove(nav, "smaller");
//         classie.remove(header, "smallerh");
//       }
//     }
//   });
// }

// window.onload = init();

// Navbar /// /// /// ///

// Show navbar shadow when scroll down and hide when on the page top
window.onscroll = function () {
	console.log('1');
	var scrolled = window.pageYOffset || document.documentElement.scrollTop;

	if (scrolled > 0) {
		document.getElementsByClassName('navbar')[0].style.boxShadow = '0 1px 6px 0 #1e8a37';
	} else {
		document.getElementsByClassName('navbar')[0].style.boxShadow = 'none';
	}
};

// Open/close burger menu
document.addEventListener('DOMContentLoaded', () => {
	// Get all "navbar-burger" elements
	const $navbarBurgers = Array.prototype.slice.call(document.querySelectorAll('.navbar-burger'), 0);

	// Check if there are any navbar burgers
	if ($navbarBurgers.length > 0) {
		// Add a click event on each of them
		$navbarBurgers.forEach((el) => {
			el.addEventListener('click', () => {
				// Get the target from the "data-target" attribute
				const target = el.dataset.target;
				const $target = document.getElementById(target);

				// Toggle the "is-active" class on both the "navbar-burger" and the "navbar-menu"
				el.classList.toggle('is-active');
				$target.classList.toggle('is-active');
			});
		});
	}
});

$(document).ready(function () {
	createSlick();
	AOS.init({
		offset: 100
	});
});

function createSlick() {
	$('.slick-track').slick({
		centerMode: true,
		infinite: true,
		slidesToShow: 2,
		slidesToScroll: 1,
		arrows: true,
		dots: true,
		autoplay: true,
		autoplaySpeed: 2000,
		prevArrow: $('.is-prev'),
		nextArrow: $('.is-next'),
		responsive: [{
			breakpoint: 600,
			settings: {
				slidesToShow: 1,
				slidesToScroll: 1
			}
		}]
	});
}

//Now it will not throw error, even if called multiple times.
$(window).on('resize', createSlick);



// [End] Navbar
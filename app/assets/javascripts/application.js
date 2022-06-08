// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require turbolinks
//= require select2
//= #require_tree .
//= require_tree ./lib/
//= require_tree ./shared/
//= require_tree ./manager/
//= require_tree ./admin/
//= require jquery.purr
//= require best_in_place
//= require best_in_place.jquery-ui
//= require interviews.js
//= require test_tasks.js
//= require questionnaires.js
//= require users_search_system.js
//= require candidate_questionnaires.js
//= require jquery-ui
//= require autocomplete-rails
//= require jquery-fileupload/basic
//= require cocoon
//= require jquery.noty.packaged.min.js
//= require airbrake
//= require croppie.js
//= require stepper.js
//= require tabs.js
//= require global-spinner.js
//= require add-csrf-token-to-request-headers.js
//= require bootstrap-datetimepicker/index.js
//= require add-number-validation-for-input-field.js
//= require throttle-decorator.js
//= require prevent-default-enter.js
//= require openPopup.js
//= require download-file.js

// eslint-disable-next-line no-undef
var airbrake = new Airbrake.Notifier({
  host: '<%= Rails.application.secrets.errbit_host %>',
  projectId: 1,
  projectKey: '<%= Rails.application.secrets.errbit_key %>'
});

airbrake.addFilter(function(notice) {
  notice.context.environment = '<%= Rails.env %>';
  return notice;
});

function remove_fields(link) {
    var el_id = $(link).closest('li').next('input[type="hidden"]');

    if (typeof el_id.val() != 'undefined') {
        $.ajax({
            url: `/questions/${el_id.val()}`,
            type: 'DELETE',
            dataType: 'json',
            success: function(data, status, req) {
                if (req.status == 200) {
                    $(link).closest('li').remove();
                    el_id.remove();
                }
            }

        });
    } else {
        $(link).closest('li').remove();
    }
}

function add_fields(link, association, content) {
    var new_id = new Date().getTime();
    var regexp = new RegExp(`new_${association}`, 'g');

    $('ol.edit-question-list').append(content.replace(regexp, new_id));
}

function showAndScrollTo(id, focus) {
    $(`#${id}`).show();
    if (focus !== null) {
        $(`#${focus}`).focus();
    }
    $('html, body').animate({ scrollTop: $(`#${id}`).offset().top }, 100);
}

function openModal(openModalBtn, modal) {
  const closeModal = $('.close-modal');
  const backgroundOverlay = $('.mm-background-overlay');

  function hidePopupOnEscapeKey(event) {
    if (event.key === 'Escape') closeModal.click();
  }

  function hidePopupOnOuterClick() {
    closeModal.click();
  }

  openModalBtn.on('click', function (event) {
    if (event.target.classList.contains('disabled')) {
      return;
    }
    modal.css('display', 'block');
    backgroundOverlay.css('display', 'block');
    $('body').css('overflow', 'hidden');
    document.querySelector('.mm-background-overlay').addEventListener('click', hidePopupOnOuterClick);
    document.addEventListener('keydown', hidePopupOnEscapeKey);
  });

  closeModal.on('click', function () {
    modal.css('display', 'none');
    backgroundOverlay.css('display', 'none');
    $('body').css('overflow', 'auto');
    document.querySelector('.mm-background-overlay').removeEventListener('click', hidePopupOnOuterClick);
    document.removeEventListener('keydown', hidePopupOnEscapeKey);
  });
}

function openCurrentModal() {
    var modal = $('#mm-modal');

    openModal($('.btn-add-interview'), modal);
    openModal($('.delete-photo'), modal);
    openModal($('.open-project-form'), modal);
    openModal($('.add-session'), modal);
    openModal($('.scale-link'), modal);
    openModal($('#selfFeedbackBackBtn'), modal);
    openModal($('#submitNonSelfFeedback'), $('#modalSubmitNonSelfFeedback'));
    openModal($('.close-session__button'), $('#mm-modal-close-session'));
    openModal($('.remove-master__button'), $('#mm-modal-remove-master'));
    openModal($('.activate-session__button'), $('#mm-modal-activate-session'));
    openModal($('.add-evaluator'), $('#mm-modal-add-evaluator'));
    openModal($('.add-peer'), $('#mm-modal-add-peer'));
    openModal($('.mm-back-settings__button'), $('#mm-modal--save-settings-notification'));
    openModal($('.apr-session-settings__button-delete'), $('#mm-modal-delete-session'));
    openModal($('.evaluators__buttons--create'), $('.add-master-modal'));
}

function highlightOption() {
    const paginationOptionElements = document.querySelectorAll('.items-on-page option');

    paginationOptionElements.forEach(function (option) {
        if (option.selected === true) {
            option.style.color = '#FD5D32';
        }
    });
}

/**
 * Hides/shows element, by adding/removing inline css display:none property
 * @param {HTMLElement} el
 * @param {boolean} toShow
 */
function toggleElementVisibility(el, toShow) {
  if (toShow) {
    // TODO: if the el initially has different display prop (e.x. flex)
    // we should get it by getComputedStyle and set to el
    el.style.display = 'block';
  } else {
    el.style.display = 'none';
  }
}

function attachHandlersToSearchField() {
    $('.search__field').focus(function () {
        $('.search-item').addClass('search-item-active');
    });

    $('body').click(function(event) {
        if (!$(event.target).closest('.search__field').length) {
            $('body').find('.search-item').removeClass('search-item-active');
        }
    });
}

function addListenerToDeletionButton() {
    const deleteSessionButton = document.querySelectorAll('.delete-session');
    const desktopOverlay = document.querySelector('.mm-background-overlay');

    deleteSessionButton.forEach(i => {
        if (i) {
            i.addEventListener('click', function () {
                i.nextElementSibling.style.display = 'block';
                desktopOverlay.style.display = 'block';
                const closeModal = document.querySelectorAll('.close-modal');

                closeModal.forEach(i => {
                    if (i) {
                        i.addEventListener('click', function () {
                            i.closest('#mm-modal-delete-session').style.display = 'none';
                        });
                    }
                });
            });
        }
    });
}

function toggleRoleSwitcherStyles() {
  const roleSwitcherContainer = document.querySelector('#role-switcher-container');
  const profileRoleSwitcher =  document.querySelector('#role-switcher__link-profile');
  const teamRoleSwitcher =  document.querySelector('#role-switcher__link-team');
  const activeButtonClass = 'role-switcher__link--active';
  const url = new URL(window.location.href);
  const urlParams = url.searchParams.get('master');

  if (!roleSwitcherContainer) return;

  if (urlParams === 'true') {
    profileRoleSwitcher.removeAttribute('href');
    profileRoleSwitcher.classList.add(activeButtonClass);
    teamRoleSwitcher.classList.remove(activeButtonClass);
  } else {
    teamRoleSwitcher.removeAttribute('href');
    teamRoleSwitcher.classList.add(activeButtonClass);
    profileRoleSwitcher.classList.remove(activeButtonClass);
  }

  if (location.host.includes('masters')) {
    roleSwitcherContainer.style.display = 'none';
  }
}

window.highlightOption = highlightOption;
window.toggleElementVisibility = toggleElementVisibility;
window.openModal = openModal;
window.addListenerToDeletionButton = addListenerToDeletionButton;

$(document).ready(attachHandlersToSearchField);
$(document).ready(addListenerToDeletionButton);
$(document).on('page:load', highlightOption).ready(highlightOption);
$(document).on('page:load', openCurrentModal).ready(openCurrentModal);
$(document).on('page:load', toggleRoleSwitcherStyles).ready(toggleRoleSwitcherStyles);

$(document).on('page:load ready', function() {
  $('input[type=file]').on('change', function() {
    var filePath = $(this).val();

    if (filePath.length > 0) {
      var split = filePath.split('\\');

      $(this).parent().find('.filename').html(split[split.length - 1]);
    }
  });
});


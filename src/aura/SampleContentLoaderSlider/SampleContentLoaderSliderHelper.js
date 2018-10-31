({
    setupComponent: function(component, event, helper) {
        function debounce(func, wait, immediate) {
            // https://davidwalsh.name/javascript-debounce-function
            // Returns a function, that, as long as it continues to be invoked, will not
            // be triggered. The function will be called after it stops being called for
            // N milliseconds. If `immediate` is passed, trigger the function on the
            // leading edge, instead of the trailing.
            var timeout;
            return function() {
                var context = this, args = arguments;
                var later = function() {
                    timeout = null;
                    if (!immediate) func.apply(context, args);
                };
                var callNow = immediate && !timeout;
                clearTimeout(timeout);
                timeout = setTimeout(later, wait);
                if (callNow) func.apply(context, args);
            };
        }

        // if the browser window changes size, reset the slider's position so that the current slide is visible
        var resizeHandler = debounce(function() {
            helper.advanceSlides(component, helper, 0);
        }, 100);
        window.addEventListener('resize', resizeHandler);

        component.set('v.contentLoadCount', event.getParam('contentLoadCount'));
        helper.startAutoAdvanceTimer(component, helper);
    },

    startAutoAdvanceTimer: function(component, helper) {
        var autoAdvanceTime = parseInt(component.get('v.advanceDelay'));
        if (component.get('v.autoAdvance') && autoAdvanceTime > 0) {
            var timer = component.get('v.autoAdvanceTimer');
            clearTimeout(timer);
            timer = setTimeout($A.getCallback(function () {
                    if (component.isValid()) {
                        helper.advanceSlides(component, helper, 1);
                    }
                }),
                autoAdvanceTime);

            component.set('v.autoAdvanceTimer', timer);
        }
    },

    advanceSlides: function(component, helper, advanceBy) {
        try {
            var container = component.find('sliderScrollContainer');
            if (container) {
                var scrollContainer = container.getElement(),
                    itemCount = component.get('v.contentLoadCount'),
                    visibleItem = component.get('v.visibleItem'),
                    nextItem = visibleItem + advanceBy;

                // wrap around and start at the beginning or end if necessary
                if (nextItem > itemCount - 1) {
                    nextItem = 0;
                } else if (nextItem < 0) {
                    nextItem = itemCount - 1;
                }
                // compute the width of the slides and use that as an offset to move the current slide in view
                // scroll speed is controlled via css transition
                var position = parseFloat(scrollContainer.clientWidth) * nextItem;
                scrollContainer.style.textIndent = (position / -1) + 'px';

                component.set('v.visibleItem', nextItem);
                helper.startAutoAdvanceTimer(component, helper); // restart the timer
            }
        } catch (e) {}
    }
})
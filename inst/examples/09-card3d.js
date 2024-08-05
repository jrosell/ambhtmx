me().on('mouseenter', ev => {
    let e = me(ev)
    e.bounds = e.getBoundingClientRect()
    e.on('mousemove', e.rotateToPointer)
}).on('mouseleave', ev => {
    let e = me(ev)
    e.off('mousemove', e.rotateToPointer)
    e.style.transform = e.style.background = ''
})

// Use a separate function for touch events to allow passive listener
function handleTouchStart(ev) {
    let e = me(ev)
    e.bounds = e.getBoundingClientRect()
    e.addEventListener('touchmove', e.rotateToPointer, { passive: true })
    e.addEventListener('touchend', handleTouchEnd, { passive: true })
}

function handleTouchEnd(ev) {
    let e = me(ev.target)
    e.removeEventListener('touchmove', e.rotateToPointer)
    e.removeEventListener('touchend', handleTouchEnd)
    e.style.transform = e.style.background = ''
}

me().addEventListener('touchstart', handleTouchStart, { passive: true })

me().rotateToPointer = ev => {
    let e = me(ev.target), b = e.bounds
    let x, y
    if (ev.type === 'touchmove') {
        x = ev.touches[0].clientX - b.x - b.width / 2
        y = ev.touches[0].clientY - b.y - b.height / 2
    } else {
        x = ev.clientX - b.x - b.width / 2
        y = ev.clientY - b.y - b.height / 2
    }
    let d = Math.hypot(x,y)
    let amt = {amt}
    e.style.transform = `scale3d(${ 1 + 0.07 * amt }, ${ 1 + 0.07 * amt }, 1.0)
                         rotate3d(${ y/100*amt }, ${ -x/100*amt }, 0, ${ Math.log(d)*2*amt }deg)`
    me('div', e).style.backgroundImage = `radial-gradient(
        circle at ${ x*2 + b.width/2 }px ${ y*2 + b.height/2 }px, #ffffff77, #0000000f)`
}
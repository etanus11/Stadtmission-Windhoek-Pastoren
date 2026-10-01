#!/bin/bash

# Overwrite/create index.html directly in the current directory
cat << 'HTML' > index.html
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Slideshow</title>
<style>
  body { 
    margin: 0; 
    background: #e8e1e1; 
    color: #111; 
    font-family: sans-serif; 
    display: flex; 
    justify-content: center; 
    align-items: center; 
    height: 100vh; 
    overflow: hidden; 
  }

  /* Base Slide Styling with Smooth Fade Transition */
  .slide { 
    position: absolute;
    top: 0;
    left: 0;
    width: 100%; 
    height: 100%; 
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    text-align: center;
    opacity: 0;
    visibility: hidden;
    transition: opacity 2s ease-in-out, visibility 1s ease-in-out;
  }

  /* Active Slide becomes visible and fades in */
  .slide.active { 
    opacity: 1;
    visibility: visible;
  }
  
  /* Photo Slide Styling */
  img { 
    max-width: 90vw; 
    max-height: 75vh; 
    object-fit: contain; 
    border: 3px solid #d4af37; 
    border-radius: 8px; 
    box-shadow: 0 4px 20px rgba(0,0,0,0.3); 
  }

  /* Caption Box Styling */
  .caption { 
    margin-top: 15px; 
    font-size: 1.6rem; 
    color: #111; 
    background: rgba(255, 255, 255, 0.9); 
    padding: 10px 20px; 
    border-radius: 6px; 
    max-width: 80vw;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1); 
    white-space: pre-wrap; /* Preserves multi-line text from .txt files */
  }

  /* Navigation Arrow Buttons */
  .nav-btn {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    background: rgba(0, 0, 0, 0.4);
    color: #ffffff;
    border: 2px solid #d4af37;
    font-size: 2.5rem;
    font-weight: bold;
    padding: 10px 18px;
    border-radius: 50%;
    cursor: pointer;
    z-index: 100;
    user-select: none;
    transition: background 0.3s ease, transform 0.2s ease;
  }

  .nav-btn:hover {
    background: rgba(212, 175, 55, 0.9);
    color: #111;
    transform: translateY(-50%) scale(1.1);
  }

  .nav-btn.prev { left: 25px; }
  .nav-btn.next { right: 25px; }

  /* Music Button Styling */
  .music-btn {
    position: absolute;
    top: 15px;
    right: 20px;
    background: rgba(0, 0, 0, 0.5);
    color: #ffffff;
    border: 2px solid #d4af37;
    font-size: 0.9rem;
    font-weight: bold;
    padding: 6px 14px;
    border-radius: 20px;
    cursor: pointer;
    z-index: 100;
    transition: background 0.3s ease, color 0.3s ease;
  }

  .music-btn:hover {
    background: #d4af37;
    color: #111;
  }

  /* Mobile responsiveness adjustments */
  @media (max-width: 768px) {
    .caption {
      font-size: 1.1rem;
      padding: 6px 12px;
    }

    .nav-btn {
      font-size: 1.8rem;
      padding: 6px 12px;
    }

    .nav-btn.prev { left: 10px; }
    .nav-btn.next { right: 10px; }

    .music-btn {
      top: 10px;
      right: 10px;
      font-size: 0.75rem;
      padding: 4px 10px;
    }
  }
</style>
</head>
<body>

<!-- Optional Background Audio Player -->
<audio id="bg-music" loop>
  <source src="Air.mp3" type="audio/mpeg">
</audio>
<button class="music-btn" id="musicBtn" title="Musik abspielen/pausieren">🎵 Musik: Aus</button>

<!-- On-screen Navigation Arrows -->
<button class="nav-btn prev" id="prevBtn" title="Previous Slide">&#10094;</button>
<button class="nav-btn next" id="nextBtn" title="Next Slide">&#10095;</button>

HTML

first=1

# Process all .webp files in natural version order (slide-1, slide-2, slide-10...)
for img in $(ls -v *.webp 2>/dev/null); do
  [ -e "$img" ] || continue
  
  base_name=$(basename "$img")
  txt_file="${img%.*}.txt"
  
  # Check if matching sidecar .txt file exists for caption
  if [ -f "$txt_file" ]; then
    caption=$(cat "$txt_file")
  else
    filename="${base_name%.*}"
    caption=$(echo "$filename" | tr '_' ' ')
  fi
  
  # Set the first slide to active on load
  if [ $first -eq 1 ]; then
    echo "  <div class=\"slide active\"><img src=\"$base_name\"><div class=\"caption\">$caption</div></div>" >> index.html
    first=0
  else
    echo "  <div class=\"slide\"><img src=\"$base_name\"><div class=\"caption\">$caption</div></div>" >> index.html
  fi
done

cat << 'HTML' >> index.html
<script>
  const slides = Array.from(document.querySelectorAll('.slide'));
  let current = 0;
  let timer;

  function showSlide(index) {
    if (!slides.length) return;
    slides[current].classList.remove('active');
    current = (index + slides.length) % slides.length;
    slides[current].classList.add('active');
  }

  function nextSlide() { showSlide(current + 1); }
  function previousSlide() { showSlide(current - 1); }

  function restartTimer() {
    clearInterval(timer);
    timer = setInterval(nextSlide, 9000); // 9-second slide interval
  }

  // Audio Control Logic
  const audio = document.getElementById('bg-music');
  const musicBtn = document.getElementById('musicBtn');

  musicBtn.addEventListener('click', function() {
    if (audio.paused) {
      audio.play();
      musicBtn.textContent = '🎵 Musik: An';
    } else {
      audio.pause();
      musicBtn.textContent = '🎵 Musik: Aus';
    }
  });

  // Navigation Arrow Click Events
  document.getElementById('prevBtn').addEventListener('click', function() {
    previousSlide();
    restartTimer();
  });

  document.getElementById('nextBtn').addEventListener('click', function() {
    nextSlide();
    restartTimer();
  });

  // Keyboard Navigation (Left / Right Arrows)
  document.addEventListener('keydown', function(event) {
    if (event.key === 'ArrowRight') {
      event.preventDefault();
      nextSlide();
      restartTimer();
    }
    if (event.key === 'ArrowLeft') {
      event.preventDefault();
      previousSlide();
      restartTimer();
    }
  });

  restartTimer();
</script>
</body>
</html>
HTML

echo "Successfully generated index.html!"

require 'ray'
Ray.game "Breakout", :size => [800, 600] do
  register { add_hook :quit, method(:exit!) }
  scene :square do
    @paused = false
    @lives = 3
    @score = 0
    #Create Ball
    @vel = [0, 3]
    @ball = Ray::Polygon.rectangle([0, 0, 15, 15], Ray::Color.blue)
    @ball.pos = [385,285]
    #Player paddle
    @ppaddle = Ray::Polygon.rectangle([0, 0, 100, 15], Ray::Color.white)
    @ppaddle.pos = [350,590]
    br=0
    @bricks = 20.times.map do
      b = Ray::Polygon.rectangle([0, 0, 35, 15], Ray::Color.red)
      b.pos = [br, 100]
      br += 40
      b
    end
    br=20
    @bricks += 20.times.map do
      b = Ray::Polygon.rectangle([0, 0, 35, 15], Ray::Color.red)
      b.pos = [br, 120]
      br += 40
      b
    end
    on :key_press, key(:p) do
      if @paused == true
        @paused = false
      else
        @paused = true
      end
    end
    always do

      if @paused == false
        if holding?(:right)
          if @ppaddle.pos.x < 700
            @ppaddle.pos += [3, 0]
          end
        elsif holding?(:left)
          if @ppaddle.pos.x > 0
            @ppaddle.pos -= [3, 0]
          end
        end

        @ball.pos += @vel
        if @ball.pos.x > 780
          @vel[0]=@vel[0]*-1
          #Fetch y value and mult by -1
        elsif @ball.pos.x < 0
          @vel[0]=@vel[0]*-1
        elsif @ball.pos.y < 0
          @vel[-1]=@vel[-1]*-1
        elsif @ball.pos.y > 585
          @lives -= 1
          @ball.pos = [385,285]
          @vel = [0, 3]
          @ppaddle.pos = [350,590]
        end
        if [@ball.pos.x, @ball.pos.y, 15, 15].to_rect.collide?([@ppaddle.pos.x, @ppaddle.pos.y, 100,15])
          @vel = [rand(-3...3), rand(-4...-2)]
        end

        #collision
        @bricks.each do |b|
          if [@ball.pos.x, @ball.pos.y, 15, 15].to_rect.collide?([b.pos.x, b.pos.y, 35,15])
            #@vel[0]=@vel[0]*-1
            @vel[1]=@vel[1]*-1
            @bricks.delete(b)
            @score += 100
          end
        end

      end
    end
    render do |win|
      if @paused == true
        win.draw text("Paused - Press P to resume", :at => [300,250], :size => 20)
      elsif @bricks.empty?
        win.draw text("Congrats, You Won!", :at => [300,250], :size => 20)
        win.draw text("Score: " + @score.to_s, :at => [5,5], :size => 20)
        win.draw text("Lives: " + @lives.to_s, :at => [700,5], :size => 20)
      elsif @lives <= 0
        win.draw text("Sorry, You Lost", :at => [300,250], :size => 20)
        win.draw text("Score: " + @score.to_s, :at => [5,5], :size => 20)
      else
        win.draw @ball
        win.draw @ppaddle
        @bricks.each do |b|
          win.draw b
        end
        win.draw text("Score: " + @score.to_s, :at => [5,5], :size => 20)
        win.draw text("Lives: " + @lives.to_s, :at => [700,5], :size => 20)
      end

    end
  end
  scenes << :square
end

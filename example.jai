#import "raylib";

main :: () {
    
    // Initialization
    //--------------------------------------------------------------------------------------
    screenWidth ::  800;
    screenHeight :: 450;

    InitWindow(screenWidth, screenHeight, "raylib [textures] examples - texture source and destination rectangles");

    // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)

    scarfy := LoadTexture("resources/scarfy.png");        // Texture loading

    frameWidth :=  scarfy.width/6;
    frameHeight := scarfy.height;

    // Source rectangle (part of the texture to use for drawing)
    sourceRec: Rectangle  =  .{ x = .0, y = .0, width = cast(float)frameWidth, height = cast(float)frameHeight };

    // Destination rectangle (screen rectangle where drawing part of texture)
     destRec : Rectangle = .{ screenWidth/2.0, screenHeight/2.0, frameWidth*2.0, frameHeight*2.0 };

    // Origin of the texture (rotation/scale point), it's relative to destination rectangle size
    origin: Vector2 = .{ cast(float)frameWidth, cast(float)frameHeight };

    rotation := 0;

    SetTargetFPS(60);
    //--------------------------------------------------------------------------------------

    // Main game loop
    // Detect window close button or ESC key
    while !WindowShouldClose() {
        // Update
        //----------------------------------------------------------------------------------
        rotation += 1;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        BeginDrawing();

            ClearBackground(RAYWHITE);

            // NOTE: Using DrawTexturePro() we can easily rotate and scale the part of the texture we draw
            // sourceRec defines the part of the texture we use for drawing
            // destRec defines the rectangle where our texture part will fit (scaling it to fit)
            // origin defines the point of the texture used as reference for rotation and scaling
            // rotation defines the texture rotation (using origin as rotation point)
            DrawTexturePro(scarfy, sourceRec, destRec, origin, cast(float)rotation, WHITE);

            DrawLine(cast(s32)destRec.x, 0, cast(s32)destRec.x, screenHeight, GRAY);
            DrawLine(0, cast(s32)destRec.y, screenWidth, cast(s32)destRec.y, GRAY);

            DrawText("(c) Scarfy sprite by Eiden Marsal", screenWidth - 200, screenHeight - 20, 10, GRAY);

        EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    UnloadTexture(scarfy);        // Texture unloading

    CloseWindow();                // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
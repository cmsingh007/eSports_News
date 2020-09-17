package com.esports.chaudhary.esportsnews;


import android.content.Intent;
import android.content.SharedPreferences;

import android.os.Bundle;

import android.os.Handler;
import android.view.WindowManager;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;


public class SplashActivity extends AppCompatActivity {

    int currday;
    int lastday;
    SharedPreferences settings;
    Button button;

    ImageView imageView;
    TextView textView, textView1;
    Animation top, bottom;


    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);





        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN
        , WindowManager.LayoutParams.FLAG_FULLSCREEN);

        imageView = findViewById(R.id.imageView);
        textView = findViewById(R.id.textView);
        textView1 = findViewById(R.id.textView2);
        top = AnimationUtils.loadAnimation(this, R.anim.top);
        bottom= AnimationUtils.loadAnimation(this, R.anim.bottom);

        imageView.setAnimation(top);
        textView.setAnimation(bottom);
        textView1.setAnimation(bottom);


        Boolean isFirstRun = getSharedPreferences("PREFERENCE", MODE_PRIVATE)
                .getBoolean("isFirstRun", true);

        if (isFirstRun){
            startActivity(new Intent(this, OnBorading.class));
            finish();
        }else {

            Thread myThread = new Thread() {
                @Override
                public void run() {
                    try {
                        sleep(2000);
                        Intent start = new Intent(getApplicationContext(), MainActivity.class);
                        startActivity(start);
                        finish();
                    } catch (Exception e) {
                    }
                }
            };
            myThread.start();
        }

        getSharedPreferences("PREFERENCE",MODE_PRIVATE).edit()
                .putBoolean("isFirstRun", false).commit();


        /*new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {

                Intent intent = new Intent(getApplicationContext(), MainActivity.class);
                startActivity(intent);
                // ActivityOptionsCompat options = ActivityOptionsCompat.makeSceneTransitionAnimation(SplashActivity.this,imageView, ViewCompat.getTransitionName(imageView));
                //                //startActivity(intent, options.toBundle());
                //                //finish();
            }
        },3000);*/

     /*
        Calendar calendar =Calendar.getInstance();
        currday = calendar.get(Calendar.DAY_OF_MONTH);
        //settings = getSharedPreferences("PREFS", 0);
        //lastday = settings.getInt("day", 0);

        Fade fade = new Fade();
        View decor = getWindow().getDecorView();
        fade.excludeTarget(decor.findViewById(R.id.action_bar_container), true);
        fade.excludeTarget(android.R.id.statusBarBackground, true);
        fade.excludeTarget(android.R.id.navigationBarBackground, true);

        getWindow().setEnterTransition(fade);
        getWindow().setExitTransition(fade);


        TextView textView = findViewById(R.id.textInfo);
        textView.setText("#CRYPTO WORLD" +
                "\n\nPowered by Code Apps Inc.");

        final ImageView imageView = findViewById(R.id.imgIcon);



        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {

                Intent intent = new Intent(getApplicationContext(), MainActivity.class);
                startActivity(intent);
                // ActivityOptionsCompat options = ActivityOptionsCompat.makeSceneTransitionAnimation(SplashActivity.this,imageView, ViewCompat.getTransitionName(imageView));
                //startActivity(intent, options.toBundle());
                finish();
            }
        },3000);

*/

 /*       Thread myThread = new Thread(){
            @Override
            public void run() {
                try{
                    Toast.makeText(SplashActivity.this, "gggc", Toast.LENGTH_SHORT).show();
                    sleep(2000);


                    if (true){
                        SharedPreferences.Editor editor = settings.edit();
                        editor.putInt("day", currday);
                        editor.commit();



                        //run code for just 1 day
                        //Intent start = new Intent(getApplicationContext(), LoginActivity.class);
                        //startActivity(start);
                        //finish();

                                new Handler().postDelayed(new Runnable() {
                                    @Override
                                    public void run() {

                                        button.setOnClickListener(new View.OnClickListener() {
                                            @Override
                                            public void onClick(View view) {
                                                Intent start = new Intent(getApplicationContext(), LoginActivity.class);
                                                startActivity(start);
                                                //finish()
                                               // Intent intent = new Intent(getApplicationContext(), LoginActivity.class);
                                               // ActivityOptionsCompat options = ActivityOptionsCompat.makeSceneTransitionAnimation(SplashActivity.this,imageView, ViewCompat.getTransitionName(imageView));
                                               // startActivity(intent, options.toBundle());
                                               // finish();
                                            }
                                        });
                                    }
                                }, 0000);


                    }

                    else{
                        Intent start = new Intent(getApplicationContext(), MainActivity.class);
                        startActivity(start);
                        finish();
                    }


                }catch (Exception e){}
            }
        };
        myThread.start();
*/
    }
}

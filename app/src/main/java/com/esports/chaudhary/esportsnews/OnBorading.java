package com.esports.chaudhary.esportsnews;

//using github library  'com.github.msayan:tutorial-view:v1.0.10'
// and github URL github.com/msayan/tutorial-view

import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.widget.Toast;

import com.hololo.tutorial.library.Step;
import com.hololo.tutorial.library.TutorialActivity;

import androidx.annotation.Nullable;

public class OnBorading extends TutorialActivity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);




        addFragment(new Step.Builder()
                .setBackgroundColor(Color.parseColor("#5454c4"))
                .setDrawable(R.drawable.screen_1)
                .build());

        addFragment(new Step.Builder()
                .setBackgroundColor(Color.parseColor("#5454c4"))
                .setDrawable(R.drawable.screen_2)
                .build());
       /* addFragment(new Step.Builder()
                .setBackgroundColor(Color.parseColor("#5454c4"))
                .setDrawable(R.drawable.screen_4)
                .build());*/
        addFragment(new Step.Builder()
                .setBackgroundColor(Color.parseColor("#5454c4"))
                .setDrawable(R.drawable.screen_3)
                .build());
        addFragment(new Step.Builder()
                .setBackgroundColor(Color.parseColor("#5454c4"))
                .setDrawable(R.drawable.screen_4)
                .build());
        /*addFragment(new Step.Builder()
                .setBackgroundColor(Color.parseColor("#5454c4"))
                .setDrawable(R.drawable.screen_5)
                .build());*/



    }

    @Override
    public void finishTutorial() {
        startActivity(new Intent(this, MainActivity.class));
        super.finishTutorial();
    }

    @Override
    public void currentFragmentPosition(int position) {

    }

    @Override
    public void onPointerCaptureChanged(boolean hasCapture) {

    }
}

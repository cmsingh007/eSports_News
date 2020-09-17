package com.esports.chaudhary.esportsnews;

import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.transition.Fade;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

public class LoginActivity extends AppCompatActivity {

    EditText editText, editText_username;
    Button button;
    TextView textView;
    FirebaseDatabase rootNode;
    DatabaseReference reference;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

       // getSupportActionBar().setDisplayOptions(ActionBar.DISPLAY_SHOW_CUSTOM);
        //getSupportActionBar().setCustomView(R.layout.actionbar_text);

        Fade fade = new Fade();
        View decor = getWindow().getDecorView();
        fade.excludeTarget(decor.findViewById(R.id.action_bar_container), true);
        fade.excludeTarget(android.R.id.statusBarBackground, true);
        fade.excludeTarget(android.R.id.navigationBarBackground, true);

        getWindow().setEnterTransition(fade);
        getWindow().setExitTransition(fade);

        editText = findViewById(R.id.editText);
        editText_username = findViewById(R.id.editText_username);
        button = findViewById(R.id.button);
        textView = findViewById(R.id.textView);

        textView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                startActivity(new Intent(getApplicationContext(), MainActivity.class));
                finish();
            }
        });


        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                rootNode = FirebaseDatabase.getInstance();
                reference = rootNode.getReference("users");

                String username = editText_username.getText().toString();
                String emailId = editText.getText().toString();

                //check entries from real time database
                if (username.isEmpty() || emailId.isEmpty()){
                    Toast.makeText(LoginActivity.this, "Please enter valid details", Toast.LENGTH_SHORT).show();
                }
                else {

                    UserHelper userHelper = new UserHelper(username, emailId);
                    //Toast.makeText(LoginActivity.this, "email is "+emailId, Toast.LENGTH_SHORT).show();

                    reference.child(emailId.replaceAll("[@.]", "")).setValue(userHelper);

                    Toast.makeText(LoginActivity.this, "Registration Successfull!", Toast.LENGTH_SHORT).show();

                    startActivity(new Intent(getApplicationContext(), MainActivity.class));
                    finish();
                }
            }
        });


    }
}
package com.esports.chaudhary.esportsnews;

import androidx.annotation.NonNull;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import androidx.appcompat.widget.SearchView;
import androidx.appcompat.widget.Toolbar;
import androidx.core.app.ActivityOptionsCompat;

import androidx.core.util.Pair;
import androidx.core.view.GravityCompat;
import androidx.core.view.ViewCompat;
import androidx.drawerlayout.widget.DrawerLayout;
import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;


import android.app.SearchManager;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;

import android.os.Handler;
import android.util.Log;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;

import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import android.widget.TextView;
import android.widget.Toast;


import com.esports.chaudhary.esportsnews.api.ApiClient;
import com.esports.chaudhary.esportsnews.api.ApiInterface;
import com.esports.chaudhary.esportsnews.models.Article;
import com.esports.chaudhary.esportsnews.models.News;
import com.facebook.ads.Ad;
import com.facebook.ads.AdError;
import com.facebook.ads.AudienceNetworkAds;
import com.facebook.ads.InterstitialAd;
import com.facebook.ads.InterstitialAdListener;
import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdLoader;
import com.google.android.gms.ads.AdRequest;

import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.formats.UnifiedNativeAd;
import com.google.android.gms.ads.initialization.InitializationStatus;
import com.google.android.gms.ads.initialization.OnInitializationCompleteListener;
import com.google.android.gms.ads.reward.RewardItem;
import com.google.android.gms.ads.reward.RewardedVideoAd;
import com.google.android.gms.ads.reward.RewardedVideoAdListener;
import com.google.android.material.navigation.NavigationView;


import java.util.ArrayList;
import java.util.List;


public class MainActivity extends AppCompatActivity implements SwipeRefreshLayout.OnRefreshListener,
        NavigationView.OnNavigationItemSelectedListener {

    public static final String API_KEY = "e35d92bbe88f4260ba89d407ed83a8c7";
    //lasey69520@estopg.com
    public static final String API_KEY2 = "2a8c16539ddf4e3fb3bbb3c44d991849";
    //menexi1175@estopg.com
    public static final String API_KEY3 = "febfa851a1824bfdba3d9443fa127092";

    //https://newsapi.org/v2/everything?domains=newsbtc.com&apiKey=e35d92bbe88f4260ba89d407ed83a8c7

    private RecyclerView recyclerView;

    private ArrayList<Article> articles = new ArrayList<>();

    private ArrayList<Object> mListItems = new ArrayList<>();

    public static final int NUMBER_OF_ADS = 5;
    private AdLoader adLoader;
    private List<UnifiedNativeAd> mNativeAds = new ArrayList<>();

    private RecyclerView.LayoutManager layoutManager;
    private Adapter adapter;
    private String TAG = MainActivity.class.getSimpleName();
    private TextView topHeadline;
    private SwipeRefreshLayout swipeRefreshLayout;

    private RelativeLayout errorLayout;
    private ImageView errorImage;
    private TextView errortitle, errorMessage;
    private Button btnRetry;
    private long backPressedTime;
    SearchView searchView;


    private com.google.android.gms.ads.AdView gadview;
    DrawerLayout drawerLayout;
    NavigationView navigationView;
    Toolbar toolbar;

    Call<News> call;
    ApiInterface apiInterface;

    String keyrordForRefresh;

    //private AdView adView;

    private InterstitialAd interstitialAd;
    int seconds = 0;
    Button button;
    int n = 8;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        MobileAds.initialize(this, new OnInitializationCompleteListener() {
            @Override
            public void onInitializationComplete(InitializationStatus initializationStatus) {
            }
        });

        AudienceNetworkAds.initialize(this);


        interstitialAd = new InterstitialAd(this, "996908380751380_996911244084427");
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                final Handler handler = new Handler();
                handler.post(new Runnable() {
                    @Override
                    public void run() {

                        interstitialAd.setAdListener(new InterstitialAdListener() {
                            @Override
                            public void onInterstitialDisplayed(Ad ad) {
                            }

                            @Override
                            public void onInterstitialDismissed(Ad ad) {
                            }

                            @Override
                            public void onError(Ad ad, AdError adError) {
                            }

                            @Override
                            public void onAdLoaded(Ad ad) {
                                interstitialAd.show();
                            }

                            @Override
                            public void onAdClicked(Ad ad) {
                            }

                            @Override
                            public void onLoggingImpression(Ad ad) {
                            }
                        });
                        interstitialAd.loadAd();

                        seconds = (n * n) * 1000;
                        n = n + 3;

                        handler.postDelayed(this, seconds);
                    }
                });

            }
        }, 17 * 1000);

/*

        gadview = findViewById(R.id.adview);
        //gadview.setAdSize(AdSize.);
        AdRequest adRequest = new AdRequest.Builder().build();
        gadview.loadAd(adRequest);
         */

        //AudienceNetworkAds.initialize(this);
        //adView = new AdView(this, "2541127589455617_2541128482788861", AdSize.BANNER_HEIGHT_50);
        //LinearLayout adContainer = (LinearLayout) findViewById(R.id.banner_container);
        //adContainer.addView(adView);
        //adView.loadAd();



        topHeadline = findViewById(R.id.top_headlines);

        swipeRefreshLayout = findViewById(R.id.swipe_refresh);
        swipeRefreshLayout.setOnRefreshListener(this);
        swipeRefreshLayout.setColorSchemeResources(R.color.colorAccent);

        recyclerView = findViewById(R.id.recyclerView);
        layoutManager = new LinearLayoutManager(MainActivity.this);
        recyclerView.setLayoutManager(layoutManager);
        recyclerView.setItemAnimator(new DefaultItemAnimator());
        recyclerView.setNestedScrollingEnabled(false);


        //loadJSON("");
        onLoadingSwipeRefresh("");

        errorLayout = findViewById(R.id.errorLayout);
        errorImage = findViewById(R.id.errorImage);
        errortitle = findViewById(R.id.errorTitle);
        errorMessage = findViewById(R.id.errorMessage);
        btnRetry = findViewById(R.id.btnRetry);


        //Navigation drawer Items
        drawerLayout = findViewById(R.id.drawer_layout);
        navigationView = findViewById(R.id.nav_view);
        toolbar = findViewById(R.id.toolbar);
        toolbar.setTitle(R.string.app_name);

        setSupportActionBar(toolbar);
        toolbar.setTitle("Home");

        navigationView.bringToFront();
        ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(this, drawerLayout, toolbar,
                R.string.nav_drawer_open, R.string.nav_drawer_close);
        drawerLayout.addDrawerListener(toggle);
        toggle.syncState();

        navigationView.setNavigationItemSelectedListener(this);
        navigationView.setCheckedItem(R.id.nav_home);

        loadNativeAds();
    }

    private void insertAdsInMenuItems() {
        if (mNativeAds.size() <= 0) {
            return;
        }

        int offset = (mListItems.size() / mNativeAds.size()) + 1;
        int index = 2;
        for (UnifiedNativeAd ad : mNativeAds) {
            mListItems.add(index, ad);
            index = index + offset;
        }
    }

    private void loadNativeAds() {

        AdLoader.Builder builder = new AdLoader.Builder(this, getString(R.string.ad_unit_id));
        adLoader = builder.forUnifiedNativeAd(
                new UnifiedNativeAd.OnUnifiedNativeAdLoadedListener() {
                    @Override
                    public void onUnifiedNativeAdLoaded(UnifiedNativeAd unifiedNativeAd) {
                        // A native ad loaded successfully, check if the ad loader has finished loading
                        // and if so, insert the ads into the list.
                        mNativeAds.add(unifiedNativeAd);
                        if (!adLoader.isLoading()) {
                            insertAdsInMenuItems();
                        }
                    }
                }).withAdListener(
                new AdListener() {
                    @Override
                    public void onAdFailedToLoad(int errorCode) {
                        // A native ad failed to load, check if the ad loader has finished loading
                        // and if so, insert the ads into the list.
                        Log.e("MainActivity", "The previous native ad failed to load. Attempting to"
                                + " load another.");
                        if (!adLoader.isLoading()) {
                            insertAdsInMenuItems();
                        }
                    }
                }).build();

        // Load the Native ads.
        adLoader.loadAds(new AdRequest.Builder().build(), NUMBER_OF_ADS);
    }


    public void loadJSON(final String keyword){

        if (keyword.isEmpty()) {
            toolbar.setTitle("Home");
            navigationView.setCheckedItem(R.id.nav_home);
        }
        else {
            toolbar.setTitle((keyword.toUpperCase())+" Trends");
        }

        errorLayout.setVisibility(View.GONE);

        topHeadline.setVisibility(View.INVISIBLE);
        swipeRefreshLayout.setRefreshing(true);

        apiInterface = ApiClient.getApiClient().create(ApiInterface.class);

        String country = Utils.getCountry();
        String language = Utils.getLanguage();

        if (keyword.length() > 0) {
            if (keyword.equalsIgnoreCase("bitcoin")) {
                keyrordForRefresh = keyword;
                toolbar.setTitle("Bitcoin Trends");
                call = apiInterface.getBitNews("bitcoin", API_KEY2);
                if (!mNativeAds.isEmpty()){
                    mNativeAds.clear();
                }
                loadNativeAds()  ;

            }
            else if (keyword.equalsIgnoreCase("ethereum")) {
                keyrordForRefresh = keyword;
                toolbar.setTitle("Ethereum Trend");
                call = apiInterface.getBitNews("ethereum", API_KEY3);
                if (!mNativeAds.isEmpty()){
                    mNativeAds.clear();
                }
                loadNativeAds();
            }
            else if (keyword.equalsIgnoreCase("coindesk.com")) {
                keyrordForRefresh = keyword;
                toolbar.setTitle("CoinDesk Trending");
                call = apiInterface.getSourceNews("coindesk.com", API_KEY2);
                if (!mNativeAds.isEmpty()){
                    mNativeAds.clear();
                }
                loadNativeAds();
            }
            else if (keyword.equalsIgnoreCase("cointelegraph.com")) {
                keyrordForRefresh = keyword;
                toolbar.setTitle("CoinTelegraph Trending");
                call = apiInterface.getSourceNews("cointelegraph.com", API_KEY3);
                if (!mNativeAds.isEmpty()){
                    mNativeAds.clear();
                }
                loadNativeAds();
            }
            else if (keyword.equalsIgnoreCase("newsbtc.com")) {
                keyrordForRefresh = keyword;
                toolbar.setTitle("newsBTC Trending");
                call = apiInterface.getSourceNews("newsbtc.com", API_KEY2);
                if (!mNativeAds.isEmpty()){
                    mNativeAds.clear();
                }
                loadNativeAds();
            }
            else if (keyword.equalsIgnoreCase("bitcoinist.com")) {
                keyrordForRefresh = keyword;
                toolbar.setTitle("Bitcoinist Trending");
                call = apiInterface.getSourceNews("bitcoinist.com", API_KEY3);
                if (!mNativeAds.isEmpty()){
                    mNativeAds.clear();
                }
                loadNativeAds();
            }
            else {
                //keyrordForRefresh = keyword;
                //Toast.makeText(this, "good", Toast.LENGTH_SHORT).show();
                call = apiInterface.getNewsSearch(keyword, language, "publishedAt", API_KEY);
            /*    if (!mNativeAds.isEmpty()){
                    mNativeAds.clear();
                }
                loadNativeAds();*/
            }
        }
        else  {
            /* this is for top-headlines from conutry
            call = apiInterface.getNews(country, API_KEY);*/
            keyrordForRefresh = keyword;
            toolbar.setTitle("Home");
            //call = apiInterface.getBitNews("blockchain", API_KEY);
            call = apiInterface.getNewsSearch("esports", language, "publishedAt", API_KEY);
        }

        final Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {

                call.enqueue(new Callback<News>() {
                    @Override
                    public void onResponse(Call<News> call, Response<News> response) {
                        if (response.isSuccessful() && response.body().getArticle() != null) {
                            if (!articles.isEmpty())
                                articles.clear();
                            if (!mListItems.isEmpty()) {
                                mListItems.clear();
                            }

                            articles = (ArrayList<Article>) response.body().getArticle();

                            for (int i =0 ; i< articles.size(); i++)
                                mListItems.add(articles.get(i));

                            insertAdsInMenuItems();

                            adapter = new Adapter(mListItems, MainActivity.this);
                            recyclerView.setAdapter(adapter);
                            adapter.notifyDataSetChanged();

                            initListener();

                            topHeadline.setVisibility(View.VISIBLE);
                            swipeRefreshLayout.setRefreshing(false);
                        }
                        else {
                            topHeadline.setVisibility(View.INVISIBLE);
                            swipeRefreshLayout.setRefreshing(false);

                            String errorCode;
                            switch (response.code()){
                                case 404:
                                    errorCode = "404 not found";
                                    break;
                                case 500:
                                    errorCode = "500 server broken";
                                    break;
                                default:
                                    errorCode = "unknown error";
                                    break;
                            }
                            showErrorMessage(R.drawable.no_result, "No Result", "Please Try Again!\n"+errorCode);
                        }
                    }

                    @Override
                    public void onFailure(Call<News> call, Throwable t) {
                        topHeadline.setVisibility(View.INVISIBLE);
                        swipeRefreshLayout.setRefreshing(false);
                        showErrorMessage(R.drawable.no_result, "Oops...", "Network Failure, Please Connect with the Internet!\n"+t.toString());
                    }
                });

            }
        },00);



    }

    private void initListener(){
        adapter.setOnItemClickListener(new Adapter.OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {

                ImageView imageView = findViewById(R.id.img);

                Intent intent = new Intent(MainActivity.this, NewsDetailActivity.class);

                Article article = (Article) articles.get(position);
                intent.putExtra("url", article.getUrl());
                intent.putExtra("title", article.getTitle());
                intent.putExtra("img", article.getUrlToImage());
                intent.putExtra("date", article.getPublishedAt());
                intent.putExtra("source", article.getSource().getName());
                intent.putExtra("author", article.getAuthor());

                Pair<View, String> pair = Pair.create((View)imageView, ViewCompat.getTransitionName(imageView));
                ActivityOptionsCompat optionsCompat = ActivityOptionsCompat.makeSceneTransitionAnimation(MainActivity.this, pair);

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN)
                    startActivity(intent, optionsCompat.toBundle());
                else
                    startActivity(intent);
            }
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {

        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.menu_main, menu);
        SearchManager searchManager = (SearchManager) getSystemService(Context.SEARCH_SERVICE);
        //final SearchView searchView = (SearchView) menu.findItem(R.id.action_search).getActionView();
        MenuItem menuItem = menu.findItem(R.id.action_search);
        searchView = (SearchView) menuItem.getActionView();

        //
        searchView.setSearchableInfo(searchManager.getSearchableInfo(getComponentName()));
        searchView.setQueryHint("Search Latest News...");
        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                if (query.length() > 2) {
                    onLoadingSwipeRefresh(query);
                }
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
               // onLoadingSwipeRefresh(newText);
                //loadJSON(newText);
                return false;
            }
        });

        menuItem.getIcon().setVisible(false, false);
        return true;

    }

    @Override
    public void onRefresh() {
        loadJSON(keyrordForRefresh);
    }

    private void onLoadingSwipeRefresh(final String keyword){
        swipeRefreshLayout.post(
                new Runnable() {
                    @Override
                    public void run() {
                        loadJSON(keyword);
                    }
                }
        );
    }

    private void showErrorMessage(int imageView, String title, String message){

        if (errorLayout.getVisibility() == View.GONE){
            errorLayout.setVisibility(View.VISIBLE);
        }

        errorImage.setImageResource(imageView);
        errortitle.setText(title);
        errorMessage.setText(message);

        btnRetry.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                onLoadingSwipeRefresh("");
            }
        });
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {

        int id = item.getItemId();

        if (id == R.id.action_About){

            AlertDialog.Builder mBuilder = new AlertDialog.Builder(MainActivity.this).setPositiveButton("Ok",null );
            View mView = getLayoutInflater().inflate(R.layout.alertdialog_layout, null);
            TextView desc = (TextView) mView.findViewById(R.id.aboutDesc);


            desc.setText("eSports News App\nVersion "+BuildConfig.VERSION_NAME+"\nDeveloped by Code Apps Inc." +
                    "\n\nThird Party license:\nhttps://newsapi.org\nhttps://square.github.io/retrofit\n" +
                    "https://bumptech.github.io/glide");

            mBuilder.setView(mView);
            AlertDialog dialog = mBuilder.create();
            dialog.show();
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onBackPressed() {

        if (drawerLayout.isDrawerOpen(GravityCompat.START)) {
            drawerLayout.closeDrawer(GravityCompat.START);
        } else {
            if (toolbar.getTitle() != "Home"){
                loadJSON("");
            }
            else {

                if (backPressedTime + 2000 > System.currentTimeMillis()) {
                    super.onBackPressed();
                    return;
                } else
                    Toast.makeText(this, "Press back again to exit!", Toast.LENGTH_SHORT).show();
                backPressedTime = System.currentTimeMillis();
            }
        }
    }

    @Override
    public boolean onNavigationItemSelected(@NonNull MenuItem item) {
        switch (item.getItemId()) {
            case R.id.nav_home:
                onLoadingSwipeRefresh("");
                break;
            case R.id.nav_home2:
                onLoadingSwipeRefresh("pubg");
                break;
            case R.id.nav_home3:
                onLoadingSwipeRefresh("gaming");
                break;
            /*case R.id.coindesk:
                onLoadingSwipeRefresh("blizzardwatch.com");
                break;
            case R.id.cointelegraph:
                onLoadingSwipeRefresh("thesportsdaily.com");
                break;*/
            case R.id.newsBTC:
                onLoadingSwipeRefresh("a16z.com");
                break;
            case R.id.bitcoinist:
                onLoadingSwipeRefresh("eurogamer.net");
                break;
            case R.id.nav_rate:
                startActivity(new Intent(Intent.ACTION_VIEW,
                        Uri.parse("https://play.google.com/store/apps/details?id=com.mohitchaudhary.cryptonewspaper")));
                break;
        }

        drawerLayout.closeDrawer(GravityCompat.START);

        return true;
    }

    @Override
    protected void onPause() {
        if (interstitialAd != null) {
            interstitialAd.destroy();
        }
        super.onPause();
    }

    @Override
    protected void onStop() {
        if (interstitialAd != null) {
            interstitialAd.destroy();
        }
        super.onStop();
    }

    @Override
    protected void onDestroy() {
        if (interstitialAd != null) {
            interstitialAd.destroy();
        }
        super.onDestroy();
    }
}
package com.thomasdalla.cordova.koc;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * This class echoes a string called from JavaScript.
 */
public class KoC extends CordovaPlugin {
    @Override
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
        if (action.equals("login")) {
            final String username = args.getString(0);
            final String password = args.getString(1);
            cordova.getThreadPool().execute(new Runnable() {
                public void run() {
                    login(username, password, callbackContext);
                }
            });
            return true;
        }
        return false;
    }

//    public static void executeGet(String url, String cookie)
//    {
//        try {
//            URL obj = new URL(url);
//            HttpURLConnection connection = (HttpURLConnection) obj.openConnection();
//            connection.setRequestMethod("GET");
//            connection.setRequestProperty("Content-Language", "en-US");
//            connection.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36");
//            connection.setRequestProperty("Cookie", cookie);
//            connection.setRequestProperty("Referer", url);
//            connection.connect();
//        }
//        catch(Exception ignored) {}
//    }

    public static Map<String, Object> executePost(String targetURL, String urlParameters, String cookie)
    {
        Map<String,Object> out = new HashMap<String, Object>();
        out.put("success", false);

        URL url;
        HttpURLConnection connection = null;
        try {
            //Create connection
            url = new URL(targetURL);
            connection = (HttpURLConnection)url.openConnection();
            connection.setRequestMethod("POST");
            connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            connection.setRequestProperty("Content-Length", "" + Integer.toString(urlParameters.getBytes().length));
            connection.setRequestProperty("Content-Language", "en-US");
            connection.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36");
            connection.setRequestProperty("Cookie", cookie);
            connection.setRequestProperty("Referer", targetURL);
            connection.setUseCaches (false);
            connection.setDoInput(true);
            connection.setDoOutput(true);

            //Send request
            DataOutputStream wr = new DataOutputStream (
                    connection.getOutputStream ());
            wr.writeBytes (urlParameters);
            wr.flush ();
            wr.close ();

            //Get Response
            InputStream is = connection.getInputStream();
            BufferedReader rd = new BufferedReader(new InputStreamReader(is));
            String line;
            StringBuffer response = new StringBuffer();
            while((line = rd.readLine()) != null) {
                response.append(line);
                response.append('\r');
            }
            rd.close();

            out.clear();
            out.put("headers", connection.getHeaderFields());
            out.put("url", connection.getURL().toString());
            out.put("response", response);
            out.put("success", true);

        } catch (Exception e) {
            out.clear();
            out.put("success", false);
        } finally {
            if(connection != null) {
                connection.disconnect();
            }
        }
        return out;
    }

    /**
     * Login to KoC and return the sessionid
     * @param username KoC username
     * @param password KoC password
     * @param callbackContext
     */
    public static void login(String username, String password, CallbackContext callbackContext) {
        if( username != null && password != null && username.length()>0 && password.length()>0 ) {
            CookieManager cookieManager = new CookieManager( null, CookiePolicy.ACCEPT_ALL );
            CookieHandler.setDefault(cookieManager);

            String urlParameters = "usrname=" + username + "&peeword=" + password;
            Map<String, Object> postResult = executePost("http://www.kingsofchaos.com/login.php", urlParameters, "country=XO; gsScrollPos=;");

            JSONObject message = new JSONObject();

            try {
                if(postResult.containsKey("success") && (Boolean) postResult.get("success")) {

                    String url = (String) postResult.get("url");
                    if(url.contains("error.php")) {
                        // Probably invalid username/pass
                        message.put("success", false);
                        message.put("error", "Invalid Username/Password");
                    }
                    else if(url.contains("bansuspend.php")) {
                        message.put("success", false);
                        message.put("error", "You have been banned!");
                    }
                    else if(url.contains("newage.php")) {
                        message.put("success", false);
                        message.put("error", "Login from a PC to start the new age!");
                    }
                    else if(url.contains("base.php")) {
                        // All good!
                        message.put("success", true);
                        List<HttpCookie> cookies = cookieManager.getCookieStore().getCookies();
                        String koc_session = "";
                        for (HttpCookie cookie : cookies) {
                            if(cookie.getName().equals("koc_session"))
                                koc_session = cookie.getValue();
                        }
                        message.put("session", koc_session );
                        // Call setres.php otherwise recruit doesn't work
                        //executeGet("http://www.kingsofchaos.com/setres.php?width=1280&height=720", "country=XO; gsScrollPos=; koc_session="+koc_session+";");
                    }
                    else {
                        // Don't know what to do
                        message.put("success", false);
                        message.put("error", "Unknown response: " + url);
                    }
                }
                else {
                    message.put("success", false);
                    message.put("error", "Error connecting to KoC...");
                }
            }
            catch(JSONException ignored) {}

            callbackContext.success( message);
        } else {
            callbackContext.error("Please specify username/password");
        }
    }

}
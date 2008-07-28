class Hebmain::Widgets::Newsletter < WidgetManager::Base
  
  def render_full
   rawtext <<-Google
<div class="newsletter">
  <h1>הרשמה לגיליון האלקטרוני</h1>
  <form class="inner" action="http://mlist.kbb1.com/subscribe/mult_subscribe_NC" method="get">
  <p>
	<input type="text" id="ml_user_email" name="ml_user[email]" onfocus="if(document.getElementById('ml_user_email').value == 'הזן כתובת e-mail') { document.getElementById('ml_user_email').value = ''; }" title="כתובת e-mail" value="הזן כתובת e-mail" />
	<input id="ml_list_ids[]" name="ml_list_ids[]" type="hidden" value="161" />
	<div class="check"><input id="ml_list_ids[]" name="ml_list_ids[]" type="checkbox" value="175" checked="ON" /></div> <div class="label">כן, אני מעוניין/ת לקבל סרטוני וידאו ישירות למייל</span></div>
	<input name="subscribe" class="button" value="הרשם" type="submit" title="הרשם" alt="הרשם" />
	<input type="hidden" name="Additional_" value="hebrew" />
	<input type="hidden" name="list" value="kabbalah" />
	<input type="hidden" name="demographics" value="Additional_" />
	<input type="hidden" name="confirm" value="none" />
    </p>
</form>
</div>
Google

  end
end
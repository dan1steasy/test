class AeMailer < ActionMailer::Base

  def account(email, recipients, sent_on = Time.now)
    @subject    = email.subject
    @body       = {:html_body => email.html_body, :text_body => email.text_body}
    @recipients = recipients
    @from       = "1st Easy Limited <support@1steasy.com>"
    @sent_on    = sent_on
    @headers    = {}
  end

  def dcp_account(contact, dcp_user, password, sent_on = Time.now)
    @subject    = "Your 1st Easy Domain Control Panel Login Details";
    @body       = {:contact => contact, :dcp_user => dcp_user,
                   :password => password}
    @recipients = contact.email
    @from       = "1st Easy Limited <support@1steasy.com>"
    @sent_on    = sent_on
    @headers    = {}
  end

end

<?php
namespace Helper;

use Swift_Mailer;
use Swift_SmtpTransport;
use Swift_Message;

class Email
{
    public static function sendMail($email, $data)
    {


        $transport = Swift_SmtpTransport::newInstance('smtp.gmail.com', 465, 'ssl')
            ->setUsername('sirajussalayhin@gmail.com')
            ->setPassword('www456789');


        $mailer = Swift_Mailer::newInstance($transport);

        $message = Swift_Message::newInstance('Forget password email')
            ->setFrom(array('info@rightbrainsolution.com' => 'Salayhin'))
            ->setTo(array($email => "Socialmaps"))
            ->setBody($data);

        $mailer->send($message);
    }
}

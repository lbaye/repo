<?php
namespace Helper;

use Swift_Mailer;
use Swift_SmtpTransport;
use Swift_Message;

/**
 * Helper for providing email related services
 * @ignore
 */
class Email
{
    public static function sendMail($email, $data)
    {
        $transport = Swift_SmtpTransport::newInstance('smtp.gmail.com', 465, 'ssl')
            ->setUsername('islam.rafiqul@genweb2.com')
            ->setPassword('*rafiq123');


        $mailer = Swift_Mailer::newInstance($transport);

        $message = Swift_Message::newInstance('Socialmaps account password reset')
            ->setFrom(array('info@genweb2.com' => 'Socialmaps admin'))
            ->setTo(array($email => "Socialmaps"))
            ->setBody($data);

        $mailer->send($message);
    }
}

bring dynamodb;
bring cloud;
bring email;
bring "../db/db.w" as Database;

pub struct Email {
  recipients: Array<str>;
}

pub class NotificationService {
    queue: cloud.Queue;
    email: email.Email;
    new() {
        let dlq = new cloud.Queue() as "DLQ";
        this.queue = new cloud.Queue({
            dlq: {
                queue: dlq,
                maxDeliveryAttempts: 5
            }
        }) as "Email Queue";

        this.email = new email.Email(sender: "hello@quickshare.app");

        nodeof(this).icon = "user-group";
        nodeof(this).color = "orange";

        this.queue.setConsumer(inflight (message: str) => {
            this.sendEmail(message);
        });


    }

    pub inflight addEmailToQueue(recipients: MutArray<str>) {
        for email in recipients {
            this.queue.push(Json.stringify({email}));
        }
    }

    pub inflight sendEmail(message: str) {
        this.email.send({
            to: ["hello@test.com"],
            subject: "You have been sent a new temporary file",
            text: "Your friend has used Quick share to send you some files."
        });

        log("SEND THE EMAIL!, {message}");
        // Send the email! with attachments? S3 info here for download?
    }
   
}



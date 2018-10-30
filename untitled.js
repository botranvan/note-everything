var ignore_persons = ['100009546159553', '100002138079607', '100025039501422', '100006076051524', '100004081532174', '100003849776953100003823366036100008096921781100013905606132100006331865619100003940474332100008638335501100001335140490100008197186506100007822564097100005353721937100005355098928100003625127193100001423744231100007264414703100007085913161100004369242044100002030808043100006234288248100003720416453100002801045635100009724900781100013342147580100007640350669100009727772255100007202915831100008440685051100005515028170100004467308822100003652869420100005231288574100003906980211100005906292517100004966782600100007680344894100015339963897100006753092019100007485695168100008856370855100010034923417100015164230010100011044391362']
var special_person = []

function autoFriends() {
    var token = '  ';
    var username = JSON.parse(atcurl('https://graph.facebook.com/me?access_token=' + token)).id
        //    Logger.log(username)
    var limit = '30';
    var friends = atcurl('https://graph.facebook.com/me?fields=friends&access_token=' + token);
    var afriends = JSON.parse(friends).friends.data;
    var feed = atcurl('https://graph.facebook.com/me/home?fields=id,from&access_token=' + token + '&limit=' + limit);
    var afeeds = JSON.parse(feed).data;
    for (var i = 0; i < afeeds.length; i++) {
        var postid = afeeds[i].id;
        var userid = afeeds[i].from ? afeeds[i].from.id : afeeds[i].id;
        for (var j = 0; j < afriends.length; j++) {
            var friendid = afriends[j].id;
            if (userid == friendid && userid != username && ignore_persons.toString().indexOf(userid) < 0) {
                var react = [];
                var content = [{
                    message: " ❤ \n https://gph.is/2MYcZA7"
                }, {
                    message: " 💗 \n https://gph.is/2lwDShV"
                }, {
                    message: " 💓 \n https://gph.is/2lz6049"
                }];
                if (react.length != 0) {
                    var type = react[Math.floor(Math.random() * react.length)];
                    var reacted = atcurl('https://graph.facebook.com/' + postid + '/reactions?summary=true&access_token=' + token);
                    var check = JSON.parse(reacted).summary.viewer_reaction;
                    if (check.error) {
                        continue
                    }
                    if (check != react) {
                        atcurl('https://graph.facebook.com/' + postid + '/reactions?type=' + type + '&method=post&access_token=' + token);
                    }
                }
                if (content.length != 0) {
                    var content = content[Math.floor(Math.random() * content.length)];
                    var commented = atcurl("https://graph.facebook.com/" + postid + "?fields=comments.limit(1000),from&access_token=" + token)
                    var checkc = JSON.parse(commented).comments
                    if (checkc.error) {
                        continue
                    }
                    if (checkc.count == 0) {
                        atcurl('https://graph.facebook.com/' + postid + '/comments/?method=post&access_token=' + token, payload = content);
                    } else {
                        if (checkc.data) {
                            var i = checkc.data.length
                            do {
                                --i
                                if (checkc.data[i].from.id == username) {
                                    return
                                };
                            } while ((checkc.data[i].from.id !== username) && i > 0)
                            atcurl('https://graph.facebook.com/' + postid + '/comments/?method=post&access_token=' + token, payload = content);
                        }
                    }
                }
            }
        }
    }
}

function atcurl(url, payload) {
    //var response = UrlFetchApp.fetch(url);
    options = {
        'muteHttpExceptions': true,
        'escaping': true,
        'payload': payload
    };
    var response = UrlFetchApp.fetch(url, options);
    return response;
}
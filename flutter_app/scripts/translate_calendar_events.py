#!/usr/bin/env python3
"""
Script to add Nepali translations (events_np) to calendar events JSON.
Uses a mapping dictionary of common event names to their Nepali equivalents.
"""

import json
from pathlib import Path

# Mapping of English event names to Nepali translations
# This includes holidays, religious events, and commemorative days
EVENT_TRANSLATIONS = {
    # Major Holidays
    "New Year": "नयाँ वर्ष",
    "Naya Barsha": "नयाँ वर्ष",
    "Loktantra Diwas": "लोकतन्त्र दिवस",
    "World Labor Day": "श्रमिक दिवस",
    "Labour Day": "श्रमिक दिवस",
    "Republic Day": "गणतन्त्र दिवस",
    "Constitution Day": "संविधान दिवस",
    "Sanvidhan Diwas": "संविधान दिवस",
    "Martyrs' Day": "शहीद दिवस",
    "Shahid Diwas": "शहीद दिवस",
    "Prithvi Jayanti": "पृथ्वी जयन्ती",
    "Democracy Day": "प्रजातन्त्र दिवस",
    "National Unity Day": "राष्ट्रिय एकता दिवस",
    "Women's Day": "महिला दिवस",
    "International Women's Day": "अन्तर्राष्ट्रिय महिला दिवस",
    "Children's Day": "बाल दिवस",
    "International Children's Day": "अन्तर्राष्ट्रिय बाल दिवस",
    "Education Day": "शिक्षा दिवस",
    "National Education Day": "राष्ट्रिय शिक्षा दिवस",

    # Dashain
    "Dashain": "दशैं",
    "Ghatasthapana": "घटस्थापना",
    "Phulpati": "फूलपाती",
    "Maha Astami": "महाअष्टमी",
    "Maha Nawami": "महानवमी",
    "Vijaya Dashami": "विजया दशमी",
    "Ekadashi": "एकादशी",
    "Dwadashi": "द्वादशी",
    "Trayodashi": "त्रयोदशी",
    "Purnimanta Kojagrat Purnima": "कोजाग्रत पूर्णिमा",

    # Tihar/Deepawali
    "Tihar": "तिहार",
    "Deepawali": "दीपावली",
    "Kag Tihar": "काग तिहार",
    "Kukur Tihar": "कुकुर तिहार",
    "Gai Tihar": "गाई तिहार",
    "Laxmi Puja": "लक्ष्मी पूजा",
    "Gobardhan Puja": "गोवर्धन पूजा",
    "Bhai Tika": "भाइ टीका",
    "Mha Puja": "म्ह पूजा",
    "Nepal Sambat New Year": "नेपाल संवत् नयाँ वर्ष",
    "Nepal Sambat": "नेपाल संवत्",

    # Holi
    "Holi": "होली",
    "Fagu Purnima": "फागु पूर्णिमा",
    "Holika Dahan": "होलिका दहन",

    # Chhath
    "Chhath": "छठ",
    "Chhath Parva": "छठ पर्व",
    "Chhath Puja": "छठ पूजा",

    # Teej/Women's festivals
    "Teej": "तीज",
    "Haritalika Teej": "हरितालिका तीज",
    "Rishi Panchami": "ऋषि पञ्चमी",

    # Janai Purnima
    "Janai Purnima": "जनै पूर्णिमा",
    "Raksha Bandhan": "रक्षाबन्धन",

    # Krishna Janmashtami
    "Krishna Janmashtami": "कृष्ण जन्माष्टमी",
    "Janmashtami": "जन्माष्टमी",
    "Krishna Astami": "कृष्ण अष्टमी",

    # Buddha related
    "Buddha Jayanti": "बुद्ध जयन्ती",
    "Buddha Purnima": "बुद्ध पूर्णिमा",

    # Shivaratri
    "Maha Shivaratri": "महाशिवरात्री",
    "Shivaratri": "शिवरात्री",

    # Saraswati Puja
    "Saraswati Puja": "सरस्वती पूजा",
    "Basanta Panchami": "बसन्त पञ्चमी",
    "Shree Panchami": "श्रीपञ्चमी",

    # Maghi
    "Maghi": "माघी",
    "Maghe Sankranti": "माघे संक्रान्ति",

    # Sonam Lhosar / Gyalpo Lhosar / Tamu Lhosar
    "Sonam Lhosar": "सोनाम ल्होसार",
    "Gyalpo Lhosar": "ग्याल्पो ल्होसार",
    "Tamu Lhosar": "तमु ल्होसार",
    "Lhosar": "ल्होसार",

    # Udhauli/Ubhauli
    "Udhauli": "उधौली",
    "Ubhauli": "उभौली",

    # Mother's/Father's Day
    "Mata Tirtha Aunshi": "माता तीर्थ औंशी",
    "Mother's Day": "आमाको मुख हेर्ने दिन",
    "Kushe Aunshi": "कुशे औंशी",
    "Gokarna Aunshi": "गोकर्ण औंशी",
    "Father's Day": "बाबुको मुख हेर्ने दिन",

    # Guru Purnima
    "Guru Purnima": "गुरु पूर्णिमा",

    # Gaura Parva
    "Gaura Parva": "गौरा पर्व",

    # Indra Jatra
    "Indra Jatra": "इन्द्र जात्रा",
    "Yenya": "येँया",

    # Ghode Jatra
    "Ghode Jatra": "घोडे जात्रा",

    # Bisket Jatra
    "Bisket Jatra": "बिस्केट जात्रा",

    # Rato Machhindranath
    "Rato Machhindranath": "रातो मछिन्द्रनाथ",
    "Machhindranath Jatra": "मछिन्द्रनाथ जात्रा",

    # Ekadashi variations
    "Ekadashibratam": "एकादशी व्रत",
    "Ekadashi Bratam": "एकादशी व्रत",
    "Kamada Ekadashibratam": "कामदा एकादशी व्रत",
    "Papamochini Ekadashibratam": "पापमोचिनी एकादशी व्रत",
    "Baruthini Ekadashibratam": "बारुथिनी एकादशी व्रत",
    "Mohini Ekadashibratam": "मोहिनी एकादशी व्रत",
    "Apara Ekadashibratam": "अपरा एकादशी व्रत",
    "Nirjala Ekadashibratam": "निर्जला एकादशी व्रत",
    "Yogini Ekadashibratam": "योगिनी एकादशी व्रत",
    "Devshayani Ekadashibratam": "देवशयनी एकादशी व्रत",
    "Kamika Ekadashibratam": "कामिका एकादशी व्रत",
    "Pavitropana Ekadashibratam": "पवित्रोपना एकादशी व्रत",
    "Aja Ekadashibratam": "अजा एकादशी व्रत",
    "Parswa Ekadashibratam": "पार्श्व एकादशी व्रत",
    "Indira Ekadashibratam": "इन्दिरा एकादशी व्रत",
    "Papakunsha Ekadashibratam": "पापांकुशा एकादशी व्रत",
    "Rama Ekadashibratam": "रमा एकादशी व्रत",
    "Devutthani Ekadashibratam": "देवउठनी एकादशी व्रत",
    "Utpanna Ekadashibratam": "उत्पन्ना एकादशी व्रत",
    "Mokshada Ekadashibratam": "मोक्षदा एकादशी व्रत",
    "Saphala Ekadashibratam": "सफला एकादशी व्रत",
    "Putrada Ekadashibratam": "पुत्रदा एकादशी व्रत",
    "Sat-tila Ekadashibratam": "षटतिला एकादशी व्रत",
    "Jaya Ekadashibratam": "जया एकादशी व्रत",
    "Bijaya Ekadashibratam": "विजया एकादशी व्रत",
    "Amalaki Ekadashibratam": "आमलकी एकादशी व्रत",
    "Padmini Ekadashibratam": "पद्मिनी एकादशी व्रत",
    "Parama Ekadashibratam": "परम एकादशी व्रत",
    "Smartanam": "स्मार्तानाम",
    "Baishnabanam": "वैष्णवानाम",

    # Purnima (Full Moon)
    "Purnima": "पूर्णिमा",
    "Purnimabratam": "पूर्णिमा व्रत",

    # Aunshi (New Moon)
    "Aunshi": "औंशी",
    "Amabasya": "अमावस्या",

    # Sankranti
    "Sankranti": "संक्रान्ति",

    # Jayanti/Birth anniversaries
    "Jayanti": "जयन्ती",
    "Parashuram Jayanti": "परशुराम जयन्ती",
    "Hanuman Jayanti": "हनुमान जयन्ती",
    "Ram Nawami": "राम नवमी",
    "Narsimha Jayanti": "नरसिंह जयन्ती",
    "Shree Sankaracharya Jayanti": "श्री शंकराचार्य जयन्ती",

    # Shraddha/Pitri Paksha
    "Shraddha": "श्राद्ध",
    "Pitri Paksha": "पितृ पक्ष",
    "Sorha Shraddha": "सोह्र श्राद्ध",

    # Other religious events
    "Akshya Tritiya": "अक्षय तृतीया",
    "Nag Panchami": "नाग पञ्चमी",
    "Gai Jatra": "गाई जात्रा",
    "Ganesh Chaturthi": "गणेश चतुर्थी",
    "Durga Puja": "दुर्गा पूजा",
    "Kartik Purnima": "कार्तिक पूर्णिमा",
    "Bala Chaturdashi": "बालचतुर्दशी",
    "Bibaha Panchami": "विवाह पञ्चमी",
    "Swasthani Bratakatha": "स्वस्थानी व्रतकथा",
    "Swasthani Purnima": "स्वस्थानी पूर्णिमा",

    # Ethnic/Regional festivals
    "Ubhauli Parva": "उभौली पर्व",
    "Sakela": "साकेला",
    "Tamu Lhosar": "तमु ल्होसार",
    "Loshar": "ल्होसार",
    "Chasok Tangnam": "चासोक टंगनाम",
    "Bhumi Puja": "भूमि पूजा",
    "Yomari Punhi": "योमरी पुन्ही",

    # World/International Days
    "World Environment Day": "विश्व वातावरण दिवस",
    "World Health Day": "विश्व स्वास्थ्य दिवस",
    "World AIDS Day": "विश्व एड्स दिवस",
    "World Population Day": "विश्व जनसंख्या दिवस",
    "World Press Freedom Day": "विश्व प्रेस स्वतन्त्रता दिवस",
    "International Yoga Day": "अन्तर्राष्ट्रिय योग दिवस",
    "Human Rights Day": "मानव अधिकार दिवस",
    "International Literacy Day": "अन्तर्राष्ट्रिय साक्षरता दिवस",
    "World Tourism Day": "विश्व पर्यटन दिवस",
    "World Food Day": "विश्व खाद्य दिवस",
    "World Habitat Day": "विश्व आवास दिवस",
    "UN Day": "संयुक्त राष्ट्र दिवस",
    "World Biodiversity Day": "विश्व जैविक विविधता दिवस",
    "World No Tobacco Day": "विश्व निषेध तम्बाकु दिवस",

    # National commemorative days
    "National Paddy Day": "राष्ट्रिय धान दिवस",
    "Ropain Diwas": "रोपाईं दिवस",
    "Baliku": "बालिकु",
    "Janaandolan Diwas": "जनआन्दोलन दिवस",

    # Mela/Jatra
    "Balaju Baiyesdhara mela": "बालाजु बाइसधारा मेला",
    "La. Pu. Matsyandranath Rath yatra arambha": "ला.पु. मत्स्येन्द्रनाथ रथयात्रा आरम्भ",
    "Bunga Dyah Jatra": "बुंगा द्य: जात्रा",

    # Other events
    "Kirant Samaj sudhar diwas": "किरात समाज सुधार दिवस",

    # Months
    "Baishakh": "बैशाख",
    "Jestha": "जेठ",
    "Ashadh": "असार",
    "Shrawan": "श्रावण",
    "Bhadra": "भाद्र",
    "Ashwin": "आश्विन",
    "Kartik": "कार्तिक",
    "Mangsir": "मंसिर",
    "Poush": "पुष",
    "Magh": "माघ",
    "Falgun": "फाल्गुण",
    "Chaitra": "चैत्र",

    # Government holidays
    "Public Holiday": "सार्वजनिक बिदा",
    "Government Holiday": "सरकारी बिदा",

    # Additional variations and common events
    "Aama Ko Mukh Herne Din": "आमाको मुख हेर्ने दिन",
    "Aama ko Mukh Herne Din": "आमाको मुख हेर्ने दिन",
    "Aama ko Mukh Herne": "आमाको मुख हेर्ने दिन",
    "Aama ko mukh herne": "आमाको मुख हेर्ने दिन",
    "Aamako Mukh Herne": "आमाको मुख हेर्ने दिन",
    "Aamako Mukh Herne din": "आमाको मुख हेर्ने दिन",
    "Aamako Mukh herne": "आमाको मुख हेर्ने दिन",
    "Aamako mukh herne": "आमाको मुख हेर्ने दिन",
    "aama ko mukh herne": "आमाको मुख हेर्ने दिन",
    "Buba Ko Mukh Herne Din": "बाबुको मुख हेर्ने दिन",
    "Buba ko Mukh Herne Din": "बाबुको मुख हेर्ने दिन",
    "Buba ko Mukh Herne": "बाबुको मुख हेर्ने दिन",
    "Buba ko mukh herne": "बाबुको मुख हेर्ने दिन",
    "Bubako Mukh Herne Din": "बाबुको मुख हेर्ने दिन",
    "Fathers Day": "बाबुको मुख हेर्ने दिन",
    "Mothers Day": "आमाको मुख हेर्ने दिन",
    "Mothers day": "आमाको मुख हेर्ने दिन",

    # Vijaya Dashami variations
    "Bijadashami": "विजया दशमी",
    "Bijaya Dashami": "विजया दशमी",
    "Bijayadashami": "विजया दशमी",
    "Bijayadashami(Tika)": "विजया दशमी (टीका)",

    # Tihar variations
    "Bhaitika": "भाइटीका",
    "Bhaitika(Kija Puja)": "भाइटीका (किजा पूजा)",
    "Kija Puja": "किजा पूजा",
    "Kukur tihar": "कुकुर तिहार",
    "Gai Puja": "गाई पूजा",
    "Goru Puja": "गोरु पूजा",
    "Gai Goru Puja": "गाई गोरु पूजा",
    "Gaidu Puja": "गाइडु पूजा",
    "Gaidu puja": "गाइडु पूजा",
    "Ox Puja": "गोरु पूजा",
    "Deep Malika": "दीपमालिका",
    "Deep Maalika": "दीपमालिका",
    "Deepmalika": "दीपमालिका",
    "Dip Malika": "दीपमालिका",
    "Dipmalika": "दीपमालिका",
    "Dipawali": "दीपावली",
    "Laxmipuja(deepawali)": "लक्ष्मीपूजा (दीपावली)",
    "Mha: Puja": "म्ह: पूजा",
    "mha puja": "म्ह: पूजा",
    "Yampanchak": "यमपञ्चक",
    "YamPanchak Aarambha": "यमपञ्चक आरम्भ",
    "Yamapanchak Aarambha": "यमपञ्चक आरम्भ",
    "Yamapanchakarambha": "यमपञ्चक आरम्भ",
    "Yampanchakarambha": "यमपञ्चक आरम्भ",
    "Yama Dwitiya": "यम द्वितीया",
    "Yam Ditiya": "यम द्वितीया",
    "Yam ditiya": "यम द्वितीया",
    "Yama Dwititya": "यम द्वितीया",
    "Yamadwitiya": "यम द्वितीया",
    "Dhanteras": "धनतेरस",
    "Dhantrayodashi": "धनत्रयोदशी",
    "Narakchaturdashi": "नरक चतुर्दशी",
    "Narak Chaturdashi": "नरक चतुर्दशी",
    "Narakchaturthi": "नरक चतुर्थी",
    "Kaak Bali": "काग बली",
    "Kaak bali": "काग बली",
    "Gobardhan puja(Gai-goru puja)": "गोवर्धन पूजा (गाई गोरु पूजा)",
    "Gowardhan Puja": "गोवर्धन पूजा",
    "Govardhan Puja": "गोवर्धन पूजा",
    "Go bali Puja": "गोबली पूजा",
    "Gobali puja": "गोबली पूजा",

    # Dashain
    "Nawaratra Aarambha": "नवरात्र आरम्भ",
    "Nawaratri Aarambha": "नवरात्री आरम्भ",
    "Nawaratri Arambha": "नवरात्री आरम्भ",
    "Navaratri Arambha": "नवरात्री आरम्भ",
    "Nawaratri Starts": "नवरात्री आरम्भ",
    "Nawaratrambha": "नवरात्र आरम्भ",
    "Nawa Ratri Aarambha": "नवरात्री आरम्भ",
    "Mahaastami": "महाअष्टमी",
    "Maha Aasthami": "महाअष्टमी",
    "Mahaasthami": "महाअष्टमी",
    "Mahaastami Brat": "महाअष्टमी व्रत",
    "Mahaasthamibratam Kulchi bhwaya": "महाअष्टमी व्रतम् कुल्ची भ्वय:",
    "Mahanawami": "महानवमी",
    "Mahanawamibratam": "महानवमी व्रतम्",
    "Nawapatrika Prabesh": "नवपत्रिका प्रवेश",
    "Nawa Patrika Prabesh": "नवपत्रिका प्रवेश",
    "Nawatrika Prabesh": "नवपत्रिका प्रवेश",
    "naba patrika prabesh": "नवपत्रिका प्रवेश",
    "Kaal Ratri": "कालरात्री",
    "Kaalratri": "कालरात्री",
    "Kalratri": "कालरात्री",
    "Kojagrat purnima": "कोजाग्रत पूर्णिमा",
    "Kojagrat Brat": "कोजाग्रत व्रत",
    "Devi Bisarjan": "देवी विसर्जन",
    "Devibisarjan": "देवी विसर्जन",
    "Devibisarjanam": "देवी विसर्जनम्",

    # Shradda variations
    "Shraddha": "श्राद्ध",
    "Shradda": "श्राद्ध",
    "Aaunshi Shradda": "औंशी श्राद्ध",
    "Aaunshi Shrada": "औंशी श्राद्ध",
    "Aastami Shradda": "अष्टमी श्राद्ध",
    "Aasthami Shradda": "अष्टमी श्राद्ध",
    "Astami Shradda": "अष्टमी श्राद्ध",
    "Asthami Shradda": "अष्टमी श्राद्ध",
    "Aastami Brat": "अष्टमी व्रत",
    "Aasthami Brat": "अष्टमी व्रत",
    "Astami Brat": "अष्टमी व्रत",
    "Asthami Brat": "अष्टमी व्रत",
    "Nawami Shradda": "नवमी श्राद्ध",
    "Nawamishraddam": "नवमी श्राद्धम्",
    "Dashami Shradda": "दशमी श्राद्ध",
    "Dashamishraddam": "दशमी श्राद्धम्",
    "Chaturdashi Shradda": "चतुर्दशी श्राद्ध",
    "Chaturdashishraddam": "चतुर्दशी श्राद्धम्",
    "Panchami Shradda": "पञ्चमी श्राद्ध",
    "Panchamishradam": "पञ्चमी श्राद्धम्",
    "Saptami Shradda": "सप्तमी श्राद्ध",
    "Saptamishraddam": "सप्तमी श्राद्धम्",
    "Sasthi Shradda": "षष्ठी श्राद्ध",
    "Shasthi Shradda": "षष्ठी श्राद्ध",
    "Sasthishraddam": "षष्ठी श्राद्धम्",
    "Tritiya Shradda": "तृतीया श्राद्ध",
    "Tritiyashraddam": "तृतीया श्राद्धम्",
    "Ditiya Shradda": "द्वितीया श्राद्ध",
    "Ditiyashraddam": "द्वितीया श्राद्धम्",
    "Dwitiya Shradda": "द्वितीया श्राद्ध",
    "Dutiya Shradda": "द्वितीया श्राद्ध",
    "Dwadashi Shradda": "द्वादशी श्राद्ध",
    "Dwudashi Shradda": "द्वादशी श्राद्ध",
    "Chaturthi Shradda": "चतुर्थी श्राद्ध",
    "Chaturthishradam": "चतुर्थी श्राद्धम्",
    "Chauthi Shradda": "चतुर्थी श्राद्ध",
    "Churthi Shradda": "चतुर्थी श्राद्ध",
    "Pratipada Shradda": "प्रतिपदा श्राद्ध",
    "Pratipadashradda": "प्रतिपदा श्राद्ध",
    "Pratibadashradda": "प्रतिपदा श्राद्ध",
    "Patipada Shradda": "प्रतिपदा श्राद्ध",
    "Darsha Shradda": "दर्श श्राद्ध",
    "Darshashradda": "दर्श श्राद्ध",
    "Darshashraddam": "दर्श श्राद्धम्",
    "Darsha Shraddam": "दर्श श्राद्धम्",
    "Darshashradam": "दर्श श्राद्धम्",
    "Darshashradam Pitri Bisharjanm": "दर्श श्राद्धम् पितृ विसर्जनम्",
    "Darshashradda Nishibarne": "दर्श श्राद्ध निशीबर्ने",
    "Sohra Shradda": "सोह्र श्राद्ध",
    "Sohra Shradda Aarambha": "सोह्र श्राद्ध आरम्भ",
    "Sohra Shradda Samapti": "सोह्र श्राद्ध समाप्ति",
    "Sorha Shradda Aarambha": "सोह्र श्राद्ध आरम्भ",
    "Sorha Shradda Starts": "सोह्र श्राद्ध आरम्भ",
    "Sorha Shradda Ends": "सोह्र श्राद्ध समाप्ति",
    "Sorhashraddha Aarambha": "सोह्र श्राद्ध आरम्भ",
    "Sohashraddarambha": "सोह्र श्राद्ध आरम्भ",
    "Sohrashradda arambha": "सोह्र श्राद्ध आरम्भ",
    "Shorashradda Aarambha": "सोह्र श्राद्ध आरम्भ",
    "Matamaha Shradda": "मातामह श्राद्ध",
    "Matrinawami Shradda": "मातृनवमी श्राद्ध",
    "Pitri Bisarjan": "पितृ विसर्जन",
    "Pitribisarjan": "पितृ विसर्जन",
    "Pitri Bisarjan (Shohra Shradda Samapti)": "पितृ विसर्जन (सोह्र श्राद्ध समाप्ति)",
    "Pitri Bisarjan (Sohra Shradda Samapti)": "पितृ विसर्जन (सोह्र श्राद्ध समाप्ति)",
    "Asthami/Nawami Shradda": "अष्टमी/नवमी श्राद्ध",
    "Asthamishraddam": "अष्टमी श्राद्धम्",

    # Janai Purnima / Raksha Bandhan
    "Janaipurnima": "जनै पूर्णिमा",
    "Rakshya Bandhan": "रक्षाबन्धन",
    "RakshyaBandhan": "रक्षाबन्धन",
    "Rakshyabandhan": "रक्षाबन्धन",
    "Rakshyabandhan(Rishitarpani)": "रक्षाबन्धन (ऋषितर्पणी)",
    "Rishi Tarpani": "ऋषि तर्पणी",
    "RishiTarpani": "ऋषि तर्पणी",
    "Rishitarpani": "ऋषि तर्पणी",
    "Rishipanchami": "ऋषिपञ्चमी",

    # Gaijatra
    "Gaijatra": "गाईजात्रा",
    "GaiJatra": "गाईजात्रा",

    # Krishna Janmashtami variations
    "Shreekrishna Janmastami": "श्रीकृष्ण जन्माष्टमी",
    "Shreekrishna Janmasthami": "श्रीकृष्ण जन्माष्टमी",
    "Shree Krishna Janmastami": "श्रीकृष्ण जन्माष्टमी",
    "Shree Krishna Janmasthami": "श्रीकृष्ण जन्माष्टमी",
    "Shreekrishna Janasthami": "श्रीकृष्ण जन्माष्टमी",

    # Teej variations
    "Haritalika Brat": "हरितालिका व्रत",

    # Shivaratri variations
    "Maha Shiva Ratri": "महाशिवरात्री",
    "Maha Shiva Ratri Brat": "महाशिवरात्री व्रत",
    "Mahashiva Ratri": "महाशिवरात्री",
    "Mahashivaratri": "महाशिवरात्री",

    # Basant Panchami / Saraswati Puja variations
    "BasantaPanchami": "बसन्त पञ्चमी",
    "Basantapanchami": "बसन्त पञ्चमी",
    "Shreepanchami": "श्रीपञ्चमी",
    "Sarashwati Puja": "सरस्वती पूजा",
    "Sarashowti Puja": "सरस्वती पूजा",
    "Sarashwoti puja": "सरस्वती पूजा",
    "Sarashwotipuja": "सरस्वती पूजा",
    "Saraswoti Puja": "सरस्वती पूजा",

    # Maghe Sankranti / Maghi variations
    "Sauane Shankranti": "सौने संक्रान्ति",
    "Saune Shangkranti": "सौने संक्रान्ति",
    "Saune Shankranti": "सौने संक्रान्ति",
    "Saaune Shankranti": "सौने संक्रान्ति",
    "Ghya: Chaku Sanlhu": "घ्या: चाकु सन्ल्हु",
    "Ghya:chaku Sanlhu": "घ्या: चाकु सन्ल्हु",
    "Khayu Sanhu": "खायु सन्हु",
    "Khayu Shanlhu": "खायु शन्ल्हु",

    # Losar variations
    "Sonam Lochar": "सोनाम ल्होसार",
    "Gyalbo Losar": "ग्याल्पो ल्होसार",
    "Gyalwo Lossar": "ग्याल्पो ल्होसार",
    "Ghalpo Losar": "ग्याल्पो ल्होसार",
    "Tamang Lhochar": "तामाङ ल्होसार",
    "Tamu Lhochar": "तमु ल्होसार",
    "Tamu Lhochhar": "तमु ल्होसार",
    "TamuLosar": "तमु ल्होसार",
    "Tamulossar": "तमु ल्होसार",
    "Tol Lhochar": "तोल ल्होसार",
    "Tol Lossar": "तोल ल्होसार",

    # Chhath variations
    "Chaath Parba": "छठ पर्व",
    "Chaath Parba ***": "छठ पर्व",
    "Chath Parba": "छठ पर्व",
    "Chath Parwa": "छठ पर्व",
    "Chatth Parba": "छठ पर्व",

    # Holi variations
    "Falgupurnima": "फागु पूर्णिमा",

    # Swasthani
    "Shree Swasthani Brat Aarambha": "श्री स्वस्थानी व्रत आरम्भ",
    "Shree Swasthani Brat Prarambha": "श्री स्वस्थानी व्रत प्रारम्भ",
    "Shree Swasthani Brat Starts": "श्री स्वस्थानी व्रत आरम्भ",
    "Shree Swasthani Brat Suru": "श्री स्वस्थानी व्रत सुरु",
    "Shree Swasthani Brat Samapti": "श्री स्वस्थानी व्रत समाप्ति",
    "Shree Swasthani Brat Ends": "श्री स्वस्थानी व्रत समाप्ति",
    "ShreeSwasthani Brata Aarambha": "श्री स्वस्थानी व्रत आरम्भ",
    "Shreeswasthani Brat Aarambha": "श्री स्वस्थानी व्रत आरम्भ",
    "Shreeswasthani Brat Samapti": "श्री स्वस्थानी व्रत समाप्ति",
    "Shreeswasthani Brat Starts": "श्री स्वस्थानी व्रत आरम्भ",
    "Shreeswasthani Brat arambha": "श्री स्वस्थानी व्रत आरम्भ",
    "Shreeswasthani Brat samapti": "श्री स्वस्थानी व्रत समाप्ति",
    "Swasthani Brat Arambha": "स्वस्थानी व्रत आरम्भ",
    "Swasthani Brat Ends": "स्वस्थानी व्रत समाप्ति",
    "Swasthani Brat Samapti": "स्वस्थानी व्रत समाप्ति",
    "Swasthani Brata Starts": "स्वस्थानी व्रत आरम्भ",

    # Indra Jatra variations
    "Indrajatra ko Linga Thadyaune": "इन्द्रजात्राको लिंगो ठड्याउने",
    "Indradhoj Patan": "इन्द्रध्वज पतन",
    "Indradhojotthan": "इन्द्रध्वजोत्थान",
    "Indradhwoj Paatan": "इन्द्रध्वज पतन",
    "Indradhwoj Patan": "इन्द्रध्वज पतन",
    "Indradhwojatthan": "इन्द्रध्वजोत्थान",
    "Indradhwojothan": "इन्द्रध्वजोत्थान",
    "Indradhwojothanam": "इन्द्रध्वजोत्थानम्",
    "Indradhwojpatan": "इन्द्रध्वज पतन",
    "Indradwojothan": "इन्द्रध्वजोत्थान",
    "Kumari Indrajatra": "कुमारी इन्द्रजात्रा",

    # Jatra variations
    "Ghode Jatra": "घोडेजात्रा",
    "Bisket Jatra": "बिस्केट जात्रा",
    "Rato Machhindranath": "रातो मछिन्द्रनाथ",
    "Machhindranath Jatra": "मछिन्द्रनाथ जात्रा",

    # Gaura Parba variations
    "Gaura Parba": "गौरा पर्व",
    "Gaura Parwa": "गौरा पर्व",
    "Gauraparba": "गौरा पर्व",
    "Gaura Saptami": "गौरा सप्तमी",
    "Gaura saptami": "गौरा सप्तमी",
    "Gauri Brata": "गौरी व्रत",

    # Nag Panchami variations
    "Naagpanchami": "नाग पञ्चमी",
    "Nagpanchami": "नाग पञ्चमी",
    "Naag Panchami": "नाग पञ्चमी",
    "Naag Panchami (Naag Tasne)": "नाग पञ्चमी (नाग टाँस्ने)",
    "Naag Tasne": "नाग टाँस्ने",
    "Naagpanchami (Naag Tasne)": "नाग पञ्चमी (नाग टाँस्ने)",

    # Guru Purnima variations
    "Gurupurnima": "गुरु पूर्णिमा",
    "Gurubyas Puja": "गुरुब्यास पूजा",

    # Gokarna Aunshi variations
    "Kushe Aaunshi": "कुशे औंशी",
    "Kushe aaunshi": "कुशे औंशी",
    "Gokarna Snan": "गोकर्ण स्नान",
    "Gokarna Snanam": "गोकर्ण स्नानम्",
    "gokarna snan": "गोकर्ण स्नान",

    # Various Brat/Vrat
    "Pradosh Brat": "प्रदोष व्रत",
    "Pradosh Brata": "प्रदोष व्रत",
    "Sompradosh Brat": "सोमप्रदोष व्रत",
    "Mahalaxmi Brat Aarambha": "महालक्ष्मी व्रत आरम्भ",
    "Mahalaxmi Brat Arambha": "महालक्ष्मी व्रत आरम्भ",
    "Mahalaxmi Brat Samapti": "महालक्ष्मी व्रत समाप्ति",
    "Chaturmas Brat Aarambha": "चातुर्मास व्रत आरम्भ",
    "Chaturmas Brat Samapti": "चातुर्मास व्रत समाप्ति",
    "Chaturmas Brat Starts": "चातुर्मास व्रत आरम्भ",
    "Chaturmas arambha": "चातुर्मास आरम्भ",
    "Wata Sabitri Brat": "वट सावित्री व्रत",
    "Ananta Chaturdashi Brat": "अनन्त चतुर्दशी व्रत",
    "Ananta Chaturdashi": "अनन्त चतुर्दशी",
    "Ganesh Chaunthi Brat": "गणेश चौथी व्रत",
    "Ganesh Chuthi Brat (Chatha:)": "गणेश चौथी व्रत (चथा:)",

    # Gunla Dharma
    "Gunla Dharma Aarambha": "गुंला धर्म आरम्भ",
    "Gunla Dharma Ends": "गुंला धर्म समाप्ति",
    "Gunla Dharma Samapti": "गुंला धर्म समाप्ति",
    "Gunla dharma Samapti": "गुंला धर्म समाप्ति",
    "Gunlaa Dharma Aarambha": "गुंला धर्म आरम्भ",
    "Gunladharma Aarambha": "गुंला धर्म आरम्भ",
    "Gunladharma Ends": "गुंला धर्म समाप्ति",
    "Gunladharma Samapti": "गुंला धर्म समाप्ति",
    "Gunladharma samapti": "गुंला धर्म समाप्ति",
    "Gunladharmarambha": "गुंला धर्म आरम्भ",
    "Gunlan Dharma Arambha": "गुंला धर्म आरम्भ",
    "Guunla Dharma Samapti": "गुंला धर्म समाप्ति",
    "Guunla Dharma Starts": "गुंला धर्म आरम्भ",
    "Guunla Dharmarambha": "गुंला धर्म आरम्भ",
    "Guunladharma Aarambha": "गुंला धर्म आरम्भ",

    # Punhi (Full Moon)
    "Gun: Punhi:": "गुं: पुन्हि:",
    "Gunpunhi": "गुंपुन्हि",
    "Yanya Punhi:": "यन्या: पुन्हि:",
    "Yanya: Punhi": "यन्या: पुन्हि:",
    "Ynanya:Punhi": "यन्या: पुन्हि:",
    "Ynenya Punhi:": "यन्या: पुन्हि:",
    "Jya: Punhi": "ज्या: पुन्हि:",
    "Jyapunhi": "ज्यापुन्हि",
    "Jyapunhi:": "ज्यापुन्हि:",
    "Lhuti Punhi": "ल्हुति पुन्हि",
    "Lhuti Punhi:": "ल्हुति पुन्हि:",
    "Lhutipunhi:": "ल्हुति पुन्हि:",
    "Lutipunhi:": "लुति पुन्हि:",
    "Mila Punhi:": "मिला पुन्हि:",
    "Dila Punhi:": "दिला पुन्हि:",
    "Sakamana Punhi:": "सकमाना पुन्हि:",
    "Sakimana Punhi:": "सकिमाना पुन्हि:",
    "Swanya Punhi": "स्वन्या पुन्हि",
    "Katim Punhi:": "कतिं पुन्हि:",
    "Si Punhi:": "सी पुन्हि:",

    # Diwas (Day)
    "Ganatantra Diwas": "गणतन्त्र दिवस",
    "Prajatantra Diwas": "प्रजातन्त्र दिवस",
    "Democaracy Day": "प्रजातन्त्र दिवस",
    "Ekata Diwas": "एकता दिवस",
    "Rastriya Ekata Diwas": "राष्ट्रिय एकता दिवस",
    "Martyrs Day": "शहीद दिवस",
    "Martyrs day": "शहीद दिवस",
    "Sahid Diwas": "शहीद दिवस",
    "Sambidhan Diwas": "संविधान दिवस",
    "Sambidhan Diwas (Rastriya Diwas)": "संविधान दिवस (राष्ट्रिय दिवस)",
    "Rastriya Diwas": "राष्ट्रिय दिवस",
    "Baal Diwas": "बाल दिवस",
    "Baaldiwas": "बाल दिवस",
    "Childrens Day": "बाल दिवस",
    "Childrens day": "बाल दिवस",
    "International Childrens Day": "अन्तर्राष्ट्रिय बाल दिवस",
    "International Child Rights Day": "अन्तर्राष्ट्रिय बाल अधिकार दिवस",
    "World Children Day": "विश्व बाल दिवस",
    "Rastriya Baal Diwas": "राष्ट्रिय बाल दिवस",
    "Bishwa Baal Diwas": "विश्व बाल दिवस",
    "Womens Day": "महिला दिवस",
    "International Womens Day": "अन्तर्राष्ट्रिय महिला दिवस",
    "International Womens day": "अन्तर्राष्ट्रिय महिला दिवस",
    "Jyapu DIwas": "ज्यापु दिवस",
    "Jyapu Diwas": "ज्यापु दिवस",
    "Hulak Diwas": "हुलाक दिवस",
    "World Hulak Diwas": "विश्व हुलाक दिवस",
    "World Postal Day": "विश्व हुलाक दिवस",
    "Radio Diwas": "रेडियो दिवस",
    "World Radio Day": "विश्व रेडियो दिवस",
    "Television Day": "टेलिभिजन दिवस",
    "World Television Day": "विश्व टेलिभिजन दिवस",
    "Kanun Diwas": "कानुन दिवस",
    "Law Day": "कानुन दिवस",
    "Law day": "कानुन दिवस",
    "Rastriya Kanun Diwas": "राष्ट्रिय कानुन दिवस",
    "Paryatan Diwas": "पर्यटन दिवस",
    "Majdur Diwas": "मजदुर दिवस",
    "International Labors Day": "अन्तर्राष्ट्रिय श्रमिक दिवस",
    "International Labours Day": "अन्तर्राष्ट्रिय श्रमिक दिवस",
    "International Workers Day": "अन्तर्राष्ट्रिय श्रमिक दिवस",
    "World Workers Day": "विश्व श्रमिक दिवस",
    "Arya Diwas": "आर्य दिवस",
    "Khelkud Patrakar Diwas": "खेलकुद पत्रकार दिवस",
    "World Sports Journalism Day": "विश्व खेलकुद पत्रकारिता दिवस",
    "Rastriya Patrakarita Diwas": "राष्ट्रिय पत्रकारिता दिवस",
    "Rastriya Photo Patrakarita Diwas": "राष्ट्रिय फोटो पत्रकारिता दिवस",
    "National Photo Journalism Day": "राष्ट्रिय फोटो पत्रकारिता दिवस",
    "National Cinema Day": "राष्ट्रिय सिनेमा दिवस",
    "Bishwo Shanti Diwas": "विश्व शान्ति दिवस",
    "Chhanda Diwas": "छन्द दिवस",
    "Chanda Diwas": "छन्द दिवस",
    "Nirwachan Diwas": "निर्वाचन दिवस",
    "Nepali Sena Diwas": "नेपाली सेना दिवस",
    "Nijamati Sewa Diwas": "निजामती सेवा दिवस",
    "Rastriya Dhan Diwas": "राष्ट्रिय धान दिवस",
    "Rastriya Dharma Sabha Diwas": "राष्ट्रिय धर्मसभा दिवस",
    "Rastriya Posak Diwas": "राष्ट्रिय पोशाक दिवस",
    "Rastriya Topi Diwas": "राष्ट्रिय टोपी दिवस",
    "National Topi Day": "राष्ट्रिय टोपी दिवस",
    "Rastriya Pustakalaya Diwas": "राष्ट्रिय पुस्तकालय दिवस",
    "Rastriya Krishi Jaibik Bibidhata Diwas": "राष्ट्रिय कृषि जैविक विविधता दिवस",
    "Rastriya Prajatantra Diwas": "राष्ट्रिय प्रजातन्त्र दिवस",
    "Bastu Diwas": "वास्तु दिवस",
    "Wastu Diwas": "वास्तु दिवस",
    "Aaraniko Smriti Diwas": "अरनिको स्मृति दिवस",
    "Araniki Smriti Diwas": "अरनिको स्मृति दिवस",
    "Araniko Smriti Diwas": "अरनिको स्मृति दिवस",
    "Rastriya Bhukampa Surakshya Diwas": "राष्ट्रिय भूकम्प सुरक्षा दिवस",
    "Rastriya Bhukampa Suraksya Diwas": "राष्ट्रिय भूकम्प सुरक्षा दिवस",
    "National Earthquake Security Day": "राष्ट्रिय भूकम्प सुरक्षा दिवस",
    "Rastriya Suchana Diwas": "राष्ट्रिय सूचना दिवस",
    "Rastriya Suchana Aayog Sthapana Diwas": "राष्ट्रिय सूचना आयोग स्थापना दिवस",
    "Rastriya Suchana Ayog Sthapana Diwas": "राष्ट्रिय सूचना आयोग स्थापना दिवस",
    "Rastriya Suchana Tatha Sanchar Prabidhi Diwas": "राष्ट्रिय सूचना तथा सञ्चार प्रविधि दिवस",
    "Rastriya Suchana Tatha Sanchar Prawidhi Diwas": "राष्ट्रिय सूचना तथा सञ्चार प्रविधि दिवस",
    "Rastriya Suchana tatha Sanchar Prabidhi Diwas": "राष्ट्रिय सूचना तथा सञ्चार प्रविधि दिवस",
    "Jana Yudda Diwas": "जन युद्ध दिवस",
    "Janaandolan Diwas": "जनआन्दोलन दिवस",
    "Kirant Samaj Sudhar Diwas": "किरात समाज सुधार दिवस",
    "Kirat Samaj Sudhar Diwas": "किरात समाज सुधार दिवस",
    "Nepal Jyotish Parishad Sthapana Diwas": "नेपाल ज्योतिष परिषद् स्थापना दिवस",
    "Rastriya Mahila Jyotish Sang Sthapana Diwas": "राष्ट्रिय महिला ज्योतिष संघ स्थापना दिवस",
    "Rastriya Mahila Jyotish Sangh Sthapana Diwas": "राष्ट्रिय महिला ज्योतिष संघ स्थापना दिवस",

    # World Health Days
    "AIDS Day": "एड्स दिवस",
    "World AIDS Day": "विश्व एड्स दिवस",
    "Cancer Day": "क्यान्सर दिवस",
    "Leprosy Day": "कुष्ठरोग दिवस",
    "World Leprosy Day": "विश्व कुष्ठरोग दिवस",
    "World Tuberclosis Day": "विश्व क्षयरोग दिवस",
    "World Tuberculosis Day": "विश्व क्षयरोग दिवस",
    "World Tuberculosis day": "विश्व क्षयरोग दिवस",
    "High Blood Pressure Day": "उच्च रक्तचाप दिवस",
    "Manasik Swasthya Diwas": "मानसिक स्वास्थ्य दिवस",
    "World  Diabeties Day": "विश्व मधुमेह दिवस",
    "World Diabeties Day": "विश्व मधुमेह दिवस",
    "World Smoke Day": "विश्व धूम्रपान दिवस",
    "World Blood Donor Day": "विश्व रक्तदाता दिवस",
    "World Blood Donors Day": "विश्व रक्तदाता दिवस",
    "National Blood Donor Day": "राष्ट्रिय रक्तदाता दिवस",
    "Redcross Day": "रेडक्रस दिवस",
    "Redcross day": "रेडक्रस दिवस",
    "Khadga yatra": "खड्ग यात्रा",
    "Khadhya Diwas": "खाद्य दिवस",
    "World Food Day": "विश्व खाद्य दिवस",

    # International Days
    "International Earth Day": "अन्तर्राष्ट्रिय पृथ्वी दिवस",
    "International Family Day": "अन्तर्राष्ट्रिय परिवार दिवस",
    "International Friendship Day": "अन्तर्राष्ट्रिय मैत्री दिवस",
    "International Helpers Day": "अन्तर्राष्ट्रिय सहायक दिवस",
    "International Olympic Day": "अन्तर्राष्ट्रिय ओलम्पिक दिवस",
    "International Slavery Eradication Day": "अन्तर्राष्ट्रिय दासत्व उन्मूलन दिवस",
    "International Youths Day": "अन्तर्राष्ट्रिय युवा दिवस",
    "International Disabilities Day": "अन्तर्राष्ट्रिय अपाङ्गता दिवस",
    "International Disabilities Day ***": "अन्तर्राष्ट्रिय अपाङ्गता दिवस",
    "International Customs Day": "अन्तर्राष्ट्रिय भन्सार दिवस",
    "International Foolish Day": "अन्तर्राष्ट्रिय मूर्ख दिवस",
    "World Refugee Day": "विश्व शरणार्थी दिवस",
    "World Sports Day": "विश्व खेलकुद दिवस",
    "World Yoga Day": "विश्व योग दिवस",
    "World Quality Day": "विश्व गुणस्तर दिवस",
    "Telecommunication Day": "दूरसञ्चार दिवस",
    "Human Rights Day": "मानव अधिकार दिवस",
    "Humans Right Day": "मानव अधिकार दिवस",
    "Valentine Day": "भ्यालेन्टाइन दिवस",
    "Christmas Day": "क्रिसमस",
    "Christmas Day ***": "क्रिसमस",
    "Esai Dharmawalambhiwaharuko Parba Christmas Day": "ईसाई धर्मावलम्बीहरुको पर्व क्रिसमस",

    # Human Trafficking
    "National Day Against Human Trafficking": "मानव बेचबिखन विरुद्धको राष्ट्रिय दिवस",
    "National Day for Human Trafficking": "मानव बेचबिखन विरुद्धको राष्ट्रिय दिवस",
    "National Day on Human Trafic": "मानव बेचबिखन विरुद्धको राष्ट्रिय दिवस",
    "Manab Bech Bikhan Birudda ko Rastriya Diwas": "मानव बेचबिखन विरुद्धको राष्ट्रिय दिवस",
    "Manab Bechbikhan Birudda ko Rastriya Diwas": "मानव बेचबिखन विरुद्धको राष्ट्रिय दिवस",
    "Manab Bechbikhan Biruddako Rastriya Diwas": "मानव बेचबिखन विरुद्धको राष्ट्रिय दिवस",
    "Sampati Suddikaran Nibaran Rastriya Diwas": "सम्पत्ति शुद्धीकरण निवारण राष्ट्रिय दिवस",

    # Untouchability/Discrimination
    "Jatiya Bhedbhab tatha Chuwachut Unmulan Rastriya Diwas": "जातीय भेदभाव तथा छुवाछुत उन्मूलन राष्ट्रिय दिवस",
    "Jatiya Bhedbhaw tatha Chuwachut Unmulan Rastriya Diwas": "जातीय भेदभाव तथा छुवाछुत उन्मूलन राष्ट्रिय दिवस",
    "Jatiya Bhedbhab tatha chuwachut unmulan rastriya diwas": "जातीय भेदभाव तथा छुवाछुत उन्मूलन राष्ट्रिय दिवस",

    # Ethnic festivals
    "Urdhyauli Parba": "उधौली पर्व",
    "Urdhyauli Parwa": "उधौली पर्व",
    "Urbhyauli Parba": "उधौली पर्व",
    "Urbhauli Parba": "उधौली पर्व",
    "Urvyauli Parba": "उधौली पर्व",
    "Urvyauli Parwa of Kirant": "किरातको उधौली पर्व",
    "Urvyauli parba of Kirant": "किरातको उधौली पर्व",
    "Udhyauli Parba": "उधौली पर्व",
    "Urdhyauli Festival of Kiranti Peoples": "किरातीहरुको उधौली पर्व",
    "Kirant Parba Urdhyauli Puja": "किरात पर्व उधौली पूजा",
    "Kiranti's Urdhyauli Parba": "किरातीको उधौली पर्व",
    "Chantyal Jatiko Rastriya Parba": "चन्त्याल जातिको राष्ट्रिय पर्व",
    "Chantyal Parba": "चन्त्याल पर्व",
    "National Festival of Chantyal": "चन्त्यालको राष्ट्रिय पर्व",
    "Thakali Faloparba": "थकाली फलो पर्व",
    "Tharu Guriya Parba": "थारु गुरिया पर्व",
    "Tharu guriya parba": "थारु गुरिया पर्व",
    "Guriya Festival of Tharu People": "थारुको गुरिया पर्व",
    "Chepang Chonam Parba": "चेपाङ चोनाम पर्व",
    "Chonam Parwa": "चोनाम पर्व",
    "Siruwa Pawani Parba (Siruwa Parba Manaune Jhapa": "सिरुवा पवनी पर्व (सिरुवा पर्व मनाउने झापा",
    "Sakela": "साकेला",
    "Chasok Tangnam": "चासोक टङ्नाम",
    "Jitiya Parba": "जितिया पर्व",
    "Jitiya Parwa": "जितिया पर्व",
    "Deuda Parba": "देउडा पर्व",
    "Chaitalo Parba": "चैताली पर्व",

    # Mela (Fair)
    "Balaju Baisdhara Mela": "बालाजु बाइसधारा मेला",
    "Balaju Baisdhara Mela (Lutipunhi:)": "बालाजु बाइसधारा मेला (लुतिपुन्हि:)",
    "Balaju Bayesdhara Mela": "बालाजु बाइसधारा मेला",
    "Balaju Bayesh Dhara Mela": "बालाजु बाइसधारा मेला",
    "Balaju Bayeshdhara Mela": "बालाजु बाइसधारा मेला",
    "balaju Baiyesdhara Mela": "बालाजु बाइसधारा मेला",
    "Tribeni Mela": "त्रिवेणी मेला",
    "Triveniharu ma Mela": "त्रिवेणीहरूमा मेला",
    "Dhaneshwor Mela": "धनेश्वर मेला",
    "Kageshwor Mela": "कागेश्वर मेला",
    "Madhav Narayan Mela": "माधव नारायण मेला",
    "Pashupati Nath Mela": "पशुपतिनाथ मेला",
    "Pashupatinath Mela": "पशुपतिनाथ मेला",
    "Nakshal Nag Pokhari Mela": "नक्साल नाग पोखरी मेला",
    "Sita Bibah Panchami Mela": "सीता विवाह पञ्चमी मेला",
    "Janakpure Sita Bibahpanchami mela": "जनकपुरे सीता विवाहपञ्चमी मेला",
    "Janakpurma Sita Bibah Panchami Mela": "जनकपुरमा सीता विवाह पञ्चमी मेला",
    "Badimalika Mela": "बडीमालिका मेला",
    "Bajura Badimalika Mela": "बाजुरा बडीमालिका मेला",
    "Gadhimai Mela Prarambha": "गढीमाई मेला प्रारम्भ",
    "Gadhimai Bishesh Puja": "गढीमाई विशेष पूजा",
    "Godawari Lalitpur 12 years Mela Starts": "गोदावरी ललितपुर १२ वर्षे मेला सुरु",
    "Godawari Lalitpur 12 years Mela Ends": "गोदावरी ललितपुर १२ वर्षे मेला समाप्त",
    "Barah Chettra Mela": "बाराह क्षेत्र मेला",
    "Matsya Narayan Mela": "मत्स्य नारायण मेला",
    "Matsyanarayan Mela": "मत्स्य नारायण मेला",
    "Matsyanarayan Mela Aarambha": "मत्स्य नारायण मेला आरम्भ",
    "Matsenarayan Mela": "मत्स्येनारायण मेला",
    "Matsenarayan Mela Starts": "मत्स्येनारायण मेला सुरु",
    "Matsenarayan Mela Ends": "मत्स्येनारायण मेला समाप्त",
    "Matsyenarayan Mela": "मत्स्येनारायण मेला",
    "Matsyenarayan Mela Samapti": "मत्स्येनारायण मेला समाप्ति",
    "Matsyendranarayan Mela": "मत्स्येन्द्रनारायण मेला",

    # Matsyendranath/Machhindranath Yatra
    "L.P. Matsyandranath Ratharohan": "ल.पु. मत्स्येन्द्रनाथ रथारोहण",
    "L.P. Matsyandranath Rathyatrarambha": "ल.पु. मत्स्येन्द्रनाथ रथयात्रारम्भ",
    "La.Pu. Matsyandranath Ratharohan": "ल.पु. मत्स्येन्द्रनाथ रथारोहण",
    "La.Pu. Matsyandranath Rathyatra Arambha": "ल.पु. मत्स्येन्द्रनाथ रथयात्रा आरम्भ",
    "Lalitpur Machhendranath Ratharohan": "ललितपुर मछिन्द्रनाथ रथारोहण",
    "Lalitpur Machhindranath Ratharohan": "ललितपुर मछिन्द्रनाथ रथारोहण",
    "Lalitpur Matsendranath Rath Yatra Arambha": "ललितपुर मत्स्येन्द्रनाथ रथ यात्रा आरम्भ",
    "Lalitpur Matsendranath Snaan": "ललितपुर मत्स्येन्द्रनाथ स्नान",
    "Lalitpur Matsyandranath Rath Yatra": "ललितपुर मत्स्येन्द्रनाथ रथ यात्रा",
    "Lalitpur Matsyandranath Ratharohan": "ललितपुर मत्स्येन्द्रनाथ रथारोहण",
    "Lalitpur Matsyandranath Rathyatra": "ललितपुर मत्स्येन्द्रनाथ रथयात्रा",
    "Lalitpur Matsyandranath Rathyatra Starts": "ललितपुर मत्स्येन्द्रनाथ रथयात्रा सुरु",
    "Lalitpur Matsyandranath Snan": "ललितपुर मत्स्येन्द्रनाथ स्नान",
    "Lalitpur Matsyendranath Rath Yatra Aarambha": "ललितपुर मत्स्येन्द्रनाथ रथ यात्रा आरम्भ",
    "Lalitpur Matsyendranath Ratharohan": "ललितपुर मत्स्येन्द्रनाथ रथारोहण",
    "Lalitpur Matsyendranath Rathyatrarambha": "ललितपुर मत्स्येन्द्रनाथ रथयात्रारम्भ",
    "Lalitpur Matsyendranath Snan": "ललितपुर मत्स्येन्द्रनाथ स्नान",
    "Lalitpur Rato Machhendranath Rath Yatra Aarambha": "ललितपुर रातो मछिन्द्रनाथ रथ यात्रा आरम्भ",
    "Lalitpur Rato Machhendranath Snan (Bungadhya: nhynwa:)": "ललितपुर रातो मछिन्द्रनाथ स्नान (बुंगाध्य: न्ह्यन्वा:)",
    "Lalitpur Rato Matsyendranath Rath Yatra Aarambha": "ललितपुर रातो मत्स्येन्द्रनाथ रथ यात्रा आरम्भ",
    "L.P. Rato Matsyendranath Snan": "ल.पु. रातो मत्स्येन्द्रनाथ स्नान",
    "L.P. Gotikhel Baitarnidham Snan": "ल.पु. गोटीखेल बैतरणीधाम स्नान",
    "L.P. Narsinha Yatra": "ल.पु. नरसिंह यात्रा",
    "Lalitpur Gotikhel Baitarni Snan": "ललितपुर गोटीखेल बैतरणी स्नान",
    "Lalitpur Gotikhel Baitarnidham Snan": "ललितपुर गोटीखेल बैतरणीधाम स्नान",
    "Lalitpur Narasimha Yatra": "ललितपुर नरसिंह यात्रा",
    "Lalitpur Narshimha Yatra": "ललितपुर नरसिंह यात्रा",
    "Lalitpur Narsimha Yatra": "ललितपुर नरसिंह यात्रा",
    "Lalitpur Bhim Jatra": "ललितपुर भीम जात्रा",
    "Seto Machhindranath Snan": "सेतो मछिन्द्रनाथ स्नान",
    "Seto Machhindranath Rath Yatra Aarambha": "सेतो मछिन्द्रनाथ रथ यात्रा आरम्भ",
    "Seto Machhindranath Rathyatra Aarambha": "सेतो मछिन्द्रनाथ रथयात्रा आरम्भ",
    "Seto Machhendranath Snan (Janawahadhyanwa": "सेतो मछिन्द्रनाथ स्नान (जनबहाध्यन्वा",
    "Seto Matsendranath Snan (Janwahadhya: nhaw)": "सेतो मत्स्येन्द्रनाथ स्नान (जन्बहाध्य: न्हो)",
    "Seto Matsyandranath Bathtaking Day": "सेतो मत्स्येन्द्रनाथ स्नान दिन",
    "Seto Matsyandranath Rath Yatra": "सेतो मत्स्येन्द्रनाथ रथ यात्रा",
    "Seto Matsyandranath Snan": "सेतो मत्स्येन्द्रनाथ स्नान",
    "Shreeswet Matysandranath Rathyatra": "श्रीश्वेत मत्स्येन्द्रनाथ रथयात्रा",
    "Nala Machhindranath Rath Yatra": "नाला मछिन्द्रनाथ रथ यात्रा",
    "Nala Machhindranath Snan (Nala nhawn)": "नाला मछिन्द्रनाथ स्नान (नाला न्हों)",
    "Nala Machindranath Rath Yatra": "नाला मछिन्द्रनाथ रथ यात्रा",
    "Nala Machindranath Snan (Nala Nhawam)": "नाला मछिन्द्रनाथ स्नान (नाला न्होम्)",
    "Matsya Narayan Rath Yatra": "मत्स्य नारायण रथ यात्रा",
    "Matyandranath Bath": "मत्स्येन्द्रनाथ स्नान",
    "Bunga Dyah Jatra": "बुंगा द्य: जात्रा",

    # Yatra (Procession)
    "Jagannath Rath Yatra": "जगन्नाथ रथ यात्रा",
    "Jagannath Rathyatra": "जगन्नाथ रथयात्रा",
    "Krishnarath Jatra": "कृष्णरथ जात्रा",
    "Shreekrishna Rathyatra": "श्रीकृष्ण रथयात्रा",
    "Guheyshwori Yatra": "गुह्येश्वरी यात्रा",
    "Guheyswori Yatra": "गुह्येश्वरी यात्रा",
    "Guhiyeshwori Jatra": "गुह्येश्वरी जात्रा",
    "Guhyeswori Jatra": "गुह्येश्वरी जात्रा",
    "Shree Guheswori Yatra": "श्री गुह्येश्वरी यात्रा",
    "Pachali Bhairab Yatra": "पाचाली भैरव यात्रा",
    "Kumar Yatra": "कुमार यात्रा",
    "Balambu Mahalaxmi Yatra": "बालम्बु महालक्ष्मी यात्रा",
    "Annapurna Yatra": "अन्नपूर्णा यात्रा",
    "Sankhuyatra": "शंखुयात्रा",
    "Ridi Chettra Rishikesh Rath Yatra": "रिडी क्षेत्र ऋषिकेश रथ यात्रा",
    "Ridichetrama Rishikesko Rath jatra": "रिडी क्षेत्रमा ऋषिकेशको रथ जात्रा",
    "Ruru Chetra Rishikesh Rath Yatra": "रुरु क्षेत्र ऋषिकेश रथ यात्रा",
    "Ruru Ridi Rishikesh Kshetra Rath Yatra": "रुरु रिडी ऋषिकेश क्षेत्र रथ यात्रा",
    "Panauti Jatra": "पनौती जात्रा",
    "Panauti Rath Yatra": "पनौती रथ यात्रा",
    "Panauti Snan": "पनौती स्नान",
    "Kirtipur Indrayani Yatra": "कीर्तिपुर इन्द्रायणी यात्रा",
    "Kirtipur Ma Indrani Yatra": "कीर्तिपुरमा इन्द्राणी यात्रा",
    "Kirtipure Indrayani Jatra": "कीर्तिपुरे इन्द्रायणी जात्रा",
    "kirtipur Indrani Jatra": "कीर्तिपुर इन्द्राणी जात्रा",
    "Deupatan ma Trishul Jatra": "देउपाटनमा त्रिशूल जात्रा",
    "Deupatan ma Trishul Yatra": "देउपाटनमा त्रिशूल यात्रा",
    "Deupatanma Trishul Yatra": "देउपाटनमा त्रिशूल यात्रा",
    "Deupatanma Trishulyatra": "देउपाटनमा त्रिशूलयात्रा",
    "Devpatanma Trishul Jatra": "देवपाटनमा त्रिशूल जात्रा",
    "Devpattanma Trishul yatra": "देवपाटनमा त्रिशूल यात्रा",
    "Dhyaupatanma Trishul Yatra": "ध्यौपाटनमा त्रिशूल यात्रा",
    "Dhaupatanma Gangamai rath yatra": "ध्यौपाटनमा गंगामाई रथ यात्रा",
    "Gangamai Rath Jatra in Devpatan": "देवपाटनमा गंगामाई रथ जात्रा",

    # Bhaktapur Jatra
    "Bhaktapur Bishwa Dhojothan": "भक्तपुर विश्वध्वजोत्थान",
    "Bhaktapur Bishwadhojothan": "भक्तपुर विश्वध्वजोत्थान",
    "Bhaktapur Bishwadhojotthan": "भक्तपुर विश्वध्वजोत्थान",
    "Bhaktapur Bisket Lingo Thadyaune": "भक्तपुर बिस्केट लिंगो ठड्याउने",
    "Bhaktapur Biswadhojpatan (Biskajatra)": "भक्तपुर विश्वध्वजपतन (बिस्काजात्रा)",
    "Bhaktapur Biswadhwojthhan": "भक्तपुर विश्वध्वजोत्थान",
    "Bishwadhwojpatan (Biska Jatra)": "विश्वध्वजपतन (बिस्का जात्रा)",
    "Bkt. Bishwadhwojpatan (Biska Jatra)": "भ.क. विश्वध्वजपतन (बिस्का जात्रा)",
    "Bkt. Biswadhwojpatan (Biskajatra)": "भ.क. विश्वध्वजपतन (बिस्काजात्रा)",
    "Bhaktapur Bramhayani Yatra": "भक्तपुर ब्रह्मायणी यात्रा",
    "Bhaktapur Chandi Bhagawati Jatra": "भक्तपुर चण्डी भगवती जात्रा",
    "Bhaktapur Chandi Bhagawati Yatra": "भक्तपुर चण्डी भगवती यात्रा",
    "Bkt Chandi Bhagawati Yatra": "भ.क. चण्डी भगवती यात्रा",

    # Snan (Bath)
    "Gosaikunda Snan Aarambha": "गोसाईकुण्ड स्नान आरम्भ",
    "Gosaikunda Snan Arambha": "गोसाईकुण्ड स्नान आरम्भ",
    "Gosaikunda Snan arambha": "गोसाईकुण्ड स्नान आरम्भ",
    "Gosaikunda Snan Starts": "गोसाईकुण्ड स्नान सुरु",
    "Gosaikunda Snanarambha": "गोसाईकुण्ड स्नानारम्भ",
    "Gosaikundasnan Aarambha": "गोसाईकुण्ड स्नान आरम्भ",
    "Goshainkunda Snanrambha": "गोसाईकुण्ड स्नानारम्भ",
    "Gosaikunda Snan Samapti": "गोसाईकुण्ड स्नान समाप्ति",
    "Gosaikunda Snan Ends": "गोसाईकुण्ड स्नान समाप्ति",
    "Gosaikunda Bath Ends": "गोसाईकुण्ड स्नान समाप्ति",
    "Gosainkunda Snan Samapti": "गोसाईकुण्ड स्नान समाप्ति",
    "Gosainkunda snan samapti": "गोसाईकुण्ड स्नान समाप्ति",
    "Dashahara": "दशहरा",
    "Dashahara Snanarambha": "दशहरा स्नानारम्भ",
    "Dashahara Tatha Gosaikunda Snanarambha": "दशहरा तथा गोसाईकुण्ड स्नानारम्भ",
    "Dasahara Snanarambha": "दशहरा स्नानारम्भ",
    "Dasaharasnan": "दशहरा स्नान",
    "Ganga Dasahara": "गंगा दशहरा",
    "Ganga Dashahara": "गंगा दशहरा",
    "Gangadashahara": "गंगा दशहरा",
    "Baisakh Snaan Samapti": "बैशाख स्नान समाप्ति",
    "Baisakh Snan Samapti": "बैशाख स्नान समाप्ति",
    "Baisakh Snan Suru": "बैशाख स्नान सुरु",
    "Baisakhsnan Starts": "बैशाख स्नान सुरु",
    "Dev Ghat ma Makar Snan Aarambha": "देवघाटमा मकर स्नान आरम्भ",
    "Devghat Makar Snan Samapti": "देवघाट मकर स्नान समाप्ति",
    "Devghat ma Makarsnan Suru": "देवघाटमा मकर स्नान सुरु",
    "Devghatma Makarsnan Samapti": "देवघाटमा मकर स्नान समाप्ति",
    "Makar Bathtaking Ends on Tanahun Devghat": "तनहुँ देवघाटमा मकर स्नान समाप्ति",
    "Makar Snan Starts": "मकर स्नान सुरु",
    "Makarsnan Ends on Devghat": "देवघाटमा मकर स्नान समाप्ति",
    "Matatirtha Snaan": "माता तीर्थ स्नान",
    "Matatirtha Snan": "माता तीर्थ स्नान",
    "Chobhar Adinath Snan (Chobhadhya: Nhawam)": "चोभार आदिनाथ स्नान (चोभाध्य: न्होम्)",
    "Chovar Adinath Snan (Chova Nhawn)": "चोभार आदिनाथ स्नान (चोभा न्हों)",
    "Snaan Daan ka lagi Aaunshi": "स्नान दान का लागि औंशी",
    "Snaandaan ka lagi aaunshi": "स्नान दान का लागि औंशी",
    "Snan Daan Aaunshi": "स्नान दान औंशी",
    "Snan Dan ko lagi aaunshi": "स्नान दान को लागि औंशी",
    "Snan and Dan garne Aaunshi(Halobarne)": "स्नान दान गर्ने औंशी (हलो बर्ने)",
    "Snandaan Aaunshi": "स्नान दान औंशी",
    "Snandaan on Barahkshetra and Gokarna": "बाराह क्षेत्र र गोकर्णमा स्नान दान",
    "Snandanadau Amwashya": "स्नान दानादौ अमावस्या",
    "Snandanka lagi Aaunshi": "स्नान दानका लागि औंशी",
    "Baitadi Bishwanath Mandir ma Ganga Dashahara Snan Mela": "बैतडी विश्वनाथ मन्दिरमा गंगा दशहरा स्नान मेला",
    "Baitadi Bishwanath Mandirma Ganga Dashahara Snan Mela": "बैतडी विश्वनाथ मन्दिरमा गंगा दशहरा स्नान मेला",
    "Baitadi Bishwanath Mandirma Puja": "बैतडी विश्वनाथ मन्दिरमा पूजा",
    "Khotang Haleshi Mahadev mela": "खोटाङ हलेशी महादेव मेला",
    "Khotang Halesi Mahadev Mela": "खोटाङ हलेशी महादेव मेला",

    # Ropain/Rice planting
    "Ropain Jatra": "रोपाइँ जात्रा",
    "Ropai Jatra": "रोपाइँ जात्रा",

    # Puja
    "Bishwakarma Puja": "विश्वकर्मा पूजा",
    "Bishwokarma Puja": "विश्वकर्मा पूजा",
    "Durga Puja": "दुर्गा पूजा",
    "Bhumipuja": "भूमिपूजा",
    "Bhumi Puja": "भूमि पूजा",
    "Surya Puja": "सूर्य पूजा",
    "Gorakhali Puja": "गोरखाली पूजा",
    "Gorakhkali Puja": "गोरखकाली पूजा",
    "Gorakhkali Puja)": "गोरखकाली पूजा",
    "Gorakhkali puja": "गोरखकाली पूजा",
    "Charhe Puja": "चर्हे पूजा",
    "Dala Puja": "डाला पूजा",
    "Yam Puja": "यम पूजा",
    "yam puja": "यम पूजा",
    "Sapta Rishi Puja": "सप्तऋषि पूजा",
    "Saptarshi Puja": "सप्तर्षि पूजा",
    "Shree Bagbhairab Parba": "श्री बागभैरव पर्व",
    "Ladi Puja (Majhi Samudaya)": "लाडी पूजा (माझी समुदाय)",
    "Mahji Samudayako Ladi Puja": "माझी समुदायको लाडी पूजा",
    "Majhi Samudaya ko Ladi Puja": "माझी समुदायको लाडी पूजा",
    "Majhi Samudayako Ladi Puja": "माझी समुदायको लाडी पूजा",
    "Gathamugcharhe Puja": "गथांमुगचर्हे पूजा",
    "Gathanmugach: Hre Puja": "गथांमुगच: र्हे पूजा",
    "Gathanmugchahre": "गथांमुगचर्हे",
    "Gathanmugcharhe": "गथांमुगचर्हे",
    "Gathemangal": "गथेमंगल",
    "Gathemangal (Gathanmug:cha:hre puja)": "गथेमंगल (गथांमुग:चा:र्हे पूजा)",
    "Ghantakarna Chaturdashi": "घण्टाकर्ण चतुर्दशी",
    "Ghantakarna Chaturdashi(Gathemangal)": "घण्टाकर्ण चतुर्दशी (गथेमंगल)",
    "Ghantakarna Chaturthi": "घण्टाकर्ण चतुर्थी",
    "Pahan (Pasa) Chahre:": "पाहन (पसा) चर्हे:",
    "Pahan Chahre": "पाहन चर्हे",
    "Jug: Cha:Hre Puja": "जुग: चा:र्हे पूजा",
    "Sithi: Nakha": "सिथी: नखः",
    "Sithi:Nakha": "सिथी: नखः",
    "Sithi:Nakha:": "सिथी: नखः",
    "Sithinakha": "सिथी नखः",
    "Sithi Nakha": "सिथी नखः",
    "Sithi:Cha:Hre": "सिथी: चा:र्हे",
    "SithiChahre Puja": "सिथी चर्हे पूजा",
    "Sithicha:hre": "सिथी चा:र्हे",
    "Sithichahre Puja": "सिथी चर्हे पूजा",
    "Sithicharhe Puja": "सिथी चर्हे पूजा",
    "Kumarsasthi": "कुमार षष्ठी",
    "Kumar Sasthi": "कुमार षष्ठी",
    "Kumar Shasthi": "कुमार षष्ठी",
    "Kumarisasthi (Sithinakha:)": "कुमारी षष्ठी (सिथी नखः)",
    "Kumarsasthi (Sithinakha:)": "कुमार षष्ठी (सिथी नखः)",
    "Kumarsasthi(sithinakha:)": "कुमार षष्ठी (सिथी नखः)",
    "Shilach:Hre Puja": "शिलाच:र्हे पूजा",
    "Matati Cha: Hre": "मातती चा: र्हे",
    "Matati Cha:hre": "मातती चा:र्हे",
    "Swatincha: hre Puja": "स्वतिन्चा: र्हे पूजा",
    "Na:Laswane Ch:he Puja": "ना:लस्वने छ:हे पूजा",

    # Mangal Chaturthi
    "Mangal Chaturthi Brat": "मंगल चतुर्थी व्रत",
    "Mangal Chaturthi Bratam": "मंगल चतुर्थी व्रतम्",
    "Mangal Chaunthi": "मंगल चौथी",
    "Mangal Chaunthi Brat": "मंगल चौथी व्रत",
    "Mangal Chauthi": "मंगल चौथी",
    "Mangal Chauthi Brat": "मंगल चौथी व्रत",
    "Mangal Chauthibrat": "मंगल चौथी व्रत",
    "Mangal Chauti Brat": "मंगल चौथी व्रत",

    # Other rituals
    "Tulashi Bibah": "तुलशी विवाह",
    "Tulashi Bibaha": "तुलशी विवाह",
    "Tulashi Bijaropan": "तुलशी बीजारोपण",
    "Tulashi Bijraropanam": "तुलशी बीजारोपणम्",
    "Tulashi Ropne": "तुलशी रोप्ने",
    "Tulashi ko Biu Charne": "तुलशीको बिउ छर्ने",
    "Tulashi ko Biu Ropne": "तुलशीको बिउ रोप्ने",
    "Tulashi ko Dal Rakhne": "तुलशीको डाल राख्ने",
    "Tulashi ko biu charne": "तुलशीको बिउ छर्ने",
    "Tulashiko Biu Charne": "तुलशीको बिउ छर्ने",
    "Wilwa Nimantran": "बिल्व निमन्त्रण",
    "Luto Falne": "लुटो फाल्ने",
    "Luto Falne Din": "लुटो फाल्ने दिन",
    "Luto Falne Ebam Ranko balne": "लुटो फाल्ने एवं राँको बाल्ने",
    "Luto falne": "लुटो फाल्ने",
    "Luto falne din": "लुटो फाल्ने दिन",
    "Luto falne yebam raanko balne": "लुटो फाल्ने एवं राँको बाल्ने",
    "Ranko Balne": "राँको बाल्ने",
    "Satbij Charne": "सातबीज छर्ने",
    "Satbij charne": "सातबीज छर्ने",
    "Shatbij Charne": "षट्बीज छर्ने",
    "Shatbij Chharne": "षट्बीज छर्ने",
    "Shatbijaropan": "षट्बीजारोपण",
    "Shatbijaropanam": "षट्बीजारोपणम्",
    "Shatbijropan": "षट्बीजारोपण",
    "Shatwij Ropne": "षट्बीज रोप्ने",
    "Aakash Dip Daan Aarambha": "आकाश दीप दान आरम्भ",
    "Aakashdeep Daan Aarambha": "आकाश दीप दान आरम्भ",
    "Aakashdipdaan Aarambha": "आकाश दीप दान आरम्भ",
    "Akashdipdaan Aarambha": "आकाश दीप दान आरम्भ",
    "Yama Deep Daan": "यम दीप दान",
    "Yama Dip Daan": "यम दीप दान",
    "Yamadip Daan": "यम दीप दान",
    "Yamdip daan": "यम दीप दान",
    "Yamadi Padaanam Dhanterash": "यम दीपादानम् धनतेरस",
    "Yan Pancha Daan": "यनपञ्चदान",
    "Yen Panchadaan": "येनपञ्चदान",
    "Yal Matya": "याल मत्य",
    "Yal Panchadaan": "याल पञ्चदान",
    "Yalamtaya": "यालमत्य",
    "Khir Khane Din": "खीर खाने दिन",
    "Rice Pudding eating Day": "खीर खाने दिन",
    "Dahi Cheura Khane Din": "दही चिउरा खाने दिन",
    "Dahi Chewra Khane Din": "दही चिउरा खाने दिन",
    "Dahi Chewra Khane din": "दही चिउरा खाने दिन",
    "Dahi Chewra Khani Din": "दही चिउरा खाने दिन",
    "Dahi Chewra khane din": "दही चिउरा खाने दिन",
    "Dahi chewra khane din": "दही चिउरा खाने दिन",
    "Dahichewra Khane Din": "दही चिउरा खाने दिन",
    "Curd Beaten Rice eating day": "दही चिउरा खाने दिन",
    "Curd Bittenrice Eating Day": "दही चिउरा खाने दिन",
    "Dar Khane Din": "दार खाने दिन",
    "Dar khane": "दार खाने",
    "Daar Khane Din": "दार खाने दिन",

    # Halobarne / Nishibarne
    "Halo Barne": "हलो बर्ने",
    "Halobarne": "हलो बर्ने",
    "Halo": "हलो",
    "Halo tatha Nishi Barne": "हलो तथा निशी बर्ने",
    "Nishi Barne": "निशी बर्ने",
    "Aaunshi Shradda(NashiBarne)": "औंशी श्राद्ध (निशीबर्ने)",
    "Aaunshi Shradda(Nashibarne)": "औंशी श्राद्ध (निशीबर्ने)",
    "Aaunshi Shradda(Nishi/Halo Barne)": "औंशी श्राद्ध (निशी/हलो बर्ने)",
    "Aaunshi Shradda(Nishi/Halobarne)": "औंशी श्राद्ध (निशी/हलो बर्ने)",
    "Aaushi shradda(Nishibarne)": "औंशी श्राद्ध (निशीबर्ने)",

    # Jayanti (Birthday)
    "Bamanjayanti": "वामन जयन्ती",
    "Barahjayanti": "वराह जयन्ती",
    "Matsyajayanti": "मत्स्य जयन्ती",
    "Matsyejayanti": "मत्स्य जयन्ती",
    "Kalkijayanti": "कल्कि जयन्ती",
    "Gurunanak jayanti": "गुरुनानक जयन्ती",
    "Ramnawami(Ramjayanti)": "रामनवमी (रामजयन्ती)",
    "Goswami Tulashi Das": "गोस्वामी तुलशी दास",

    # Astami variations
    "Bhairabastami": "भैरवाष्टमी",
    "Bhairawastami": "भैरवाष्टमी",
    "Bhimastami": "भीमाष्टमी",
    "Baumasthmi": "बौमाष्टमी",
    "Bhaumastami": "भौमाष्टमी",
    "Bhaumastami Brat": "भौमाष्टमी व्रत",
    "Budhaastami": "बुधाष्टमी",
    "Budhastami Brat": "बुधाष्टमी व्रत",
    "Durbaastami": "दुर्बाष्टमी",
    "Durwastami": "दुर्बाष्टमी",
    "Shitalastami": "शीतलाष्टमी",
    "Radha Aastami": "राधाष्टमी",
    "Radha Astami": "राधाष्टमी",
    "Radhasthami": "राधाष्टमी",
    "Bayu Aastami": "वायु अष्टमी",
    "Bayu Astami": "वायु अष्टमी",
    "Kaya Aastami": "काया अष्टमी",
    "Kaya Astami": "काया अष्टमी",
    "Bhal Bhal Aastami": "भल भल अष्टमी",
    "Bhalbhal Aastami": "भल भल अष्टमी",

    # Saptami
    "Bhanu Saptami": "भानु सप्तमी",
    "Rabi Saptami": "रवि सप्तमी",
    "Achalaa Saptami": "अचला सप्तमी",
    "Amuktabharan saptami wrat": "अमुक्ताभरण सप्तमी व्रत",
    "Gangotpati(Ganga Saptami)": "गंगोत्पत्ति (गंगा सप्तमी)",

    # Purnima
    "Dhanya purnima": "धान्य पूर्णिमा",
    "Dhanyapurnima": "धान्य पूर्णिमा",
    "Chandi purnima": "चण्डी पूर्णिमा",
    "Chandipurnima": "चण्डी पूर्णिमा",

    # Grahan (Eclipse)
    "Chandra Ghrahan": "चन्द्र ग्रहण",
    "Chandra Grahan": "चन्द्र ग्रहण",
    "Surya Grahan": "सूर्य ग्रहण",
    "Khagras Chandra Grahan": "खग्रास चन्द्र ग्रहण",
    "Khagras Chandragrahan": "खग्रास चन्द्र ग्रहण",
    "Khagrash Chandragrahan": "खग्रास चन्द्र ग्रहण",
    "Khandagras Chandragraha": "खण्डग्रास चन्द्र ग्रहण",
    "Khandagras Chandragrahan": "खण्डग्रास चन्द्र ग्रहण",
    "Khandagras Suryagrahan": "खण्डग्रास सूर्य ग्रहण",

    # Tritiya/Akshaya
    "Aachyaya Tritiya": "अक्षय तृतीया",
    "Aakshya Tritiya": "अक्षय तृतीया",
    "Aakshyaya Tritiya": "अक्षय तृतीया",
    "Akashaya Tritiya": "अक्षय तृतीया",
    "Akshaya Tritiya": "अक्षय तृतीया",
    "Akshyaya Tritiya": "अक्षय तृतीया",
    "Tritiya": "तृतीया",

    # Nawami
    "Guga Nawami": "गुगा नवमी",
    "Kushmanda Nawami": "कुष्माण्ड नवमी",
    "Kusmanda Nawami": "कुष्माण्ड नवमी",

    # Other days
    "Baikuntha Chaturdashi": "बैकुण्ठ चतुर्दशी",
    "Bishnu Baikuntha Chaturdashi Brat": "विष्णु बैकुण्ठ चतुर्दशी व्रत",
    "Shiva Baikuntha Chatudashi Brat": "शिव बैकुण्ठ चतुर्दशी व्रत",
    "Shiva Baikuntha Chaturdashi Brat": "शिव बैकुण्ठ चतुर्दशी व्रत",
    "Pishach Chaturdashi": "पिशाच चतुर्दशी",
    "Karawa Chauth": "करवा चौथ",
    "Biruda Panchami": "विरुद पञ्चमी",
    "Bibah Panchami": "विवाह पञ्चमी",
    "Shiva Parbati Bibah": "शिव पार्वती विवाह",
    "Shiva Parbati Bihah": "शिव पार्वती विवाह",
    "Gayamauni Aaunshi": "गयामौनी औंशी",
    "Gayamauni Darsha Shraddam": "गयामौनी दर्श श्राद्धम्",
    "Kaushiki Utpati": "कौशिकी उत्पत्ति",
    "Chandrodaya": "चन्द्रोदय",
    "Pratipada": "प्रतिपदा",

    # Newar Calendar
    "Nakwa: Disi": "नक्वा: दिसी",
    "Nanichaya": "ननीचय",
    "Dilacha:Hre:": "दिलाचा:र्हे:",
    "Mhaipru Nakuma": "म्हैप्रु नकुमा",
    "Chirswayagu": "चिर्स्वयागु",
    "Chirothan": "चिरोत्थान",
    "Chirothhan": "चिरोत्थान",
    "Chirotthan": "चिरोत्थान",
    "Chirotyan": "चिरोत्यान",
    "Chirdaha": "चिर्दाहा",
    "Kulachi bhyaya": "कुलची भ्यय",
    "Kuchhi byha": "कुच्छी ब्याहा",
    "Yakhya": "यख्या",
    "Upaku": "उपाकु",
    "Musyaduli": "मुस्यादुली",
    "Syakwa: Tyakwa:": "स्याक्वा: त्याक्वा:",
    "Shyakwatyakwa": "श्याक्वात्याक्वा",
    "Manwadi": "मन्वादी",
    "Manwadi: (Shyakwatyakwa": "मन्वादी: (श्याक्वात्याक्वा",
    "Janwahadhanhub": "जन्वाहाधन्हुब",
    "Janwahadhya: Nhawam:": "जन्वाहाध्य: न्होम्:",
    "Janwahadhya: nhawn:": "जन्वाहाध्य: न्हों:",

    # Adhikmas
    "Adhikmas Aarambha": "अधिकमास आरम्भ",
    "Adhikmas Samapti": "अधिकमास समाप्ति",

    # New Year variations
    "English New year 2016 AD Starts": "अंग्रेजी नयाँ वर्ष २०१६ इ.सं. सुरु",
    "2020 AD Starts": "२०२० इ.सं. सुरु",
    "2021 AD Starts": "२०२१ इ.सं. सुरु",
    "2022 AD Starts": "२०२२ इ.सं. सुरु",
    "2023 AD Starts": "२०२३ इ.सं. सुरु",
    "2025 AD Starts": "२०२५ इ.सं. सुरु",
    "Nepali Sambat 1139 starts": "नेपाल संवत् ११३९ सुरु",
    "N.S. 1132 Starts": "ने.सं. ११३२ सुरु",
    "N.S. 1142 Starts": "ने.सं. ११४२ सुरु",
    "N.S. 1144 Starts": "ने.सं. ११४४ सुरु",
    "Ne.Sa. 1133 starts": "ने.सं. ११३३ सुरु",
    "Ne. Sa. 1134 Prarambha": "ने.सं. ११३४ प्रारम्भ",
    "Depawali 2074": "दीपावली २०७४",

    # Seasons
    "Basanta Ritu Starts": "बसन्त ऋतु सुरु",
    "Basanta Srawan": "बसन्त श्रावण",
    "Spring Season Starts": "बसन्त ऋतु सुरु",
    "Shortest Day": "सबैभन्दा छोटो दिन",

    # Pashupati
    "Pashupanith": "पशुपतिनाथ",
    "Pashupati Kshetrama Madhav Narayan Mela": "पशुपति क्षेत्रमा माधव नारायण मेला",
    "Pashupatinathko Chaya darshan": "पशुपतिनाथको छाया दर्शन",
    "Pashupatinath ko Chayan Darshan": "पशुपतिनाथको छायाँ दर्शन",
    "Shree Pashupati Nath ma Chayan Darshan": "श्री पशुपतिनाथमा छायाँ दर्शन",
    "Swayambhu ko Chayan Darshan": "स्वयम्भूको छायाँ दर्शन",
    "Changunarayan Akhandadeep Darshan": "चाँगुनारायण अखण्डदीप दर्शन",
    "Changunarayan Akhandadip Darshan": "चाँगुनारायण अखण्डदीप दर्शन",
    "Aryaghatma Madhav Narayan Mela": "आर्यघाटमा माधव नारायण मेला",
    "Changuma Madhav Narayan Mela": "चंगुमा माधव नारायण मेला",

    # Jumla
    "Jumla Khalanga Chandan Nath ko Lingo Thadyaune": "जुम्ला खलंगा चन्दननाथको लिंगो ठड्याउने",
    "Jumla Khalanga ma Chandannathko Lingo Thadyaune": "जुम्ला खलंगामा चन्दननाथको लिंगो ठड्याउने",
    "Jumla Khalangama Chandan Nath ko Lingo Thadyaune": "जुम्ला खलंगामा चन्दननाथको लिंगो ठड्याउने",
    "Jumla Khalangama Chandannath ko Lingo Thadyaune": "जुम्ला खलंगामा चन्दननाथको लिंगो ठड्याउने",
    "Jumla Khalangama Chandannathko lingo thadyaune": "जुम्ला खलंगामा चन्दननाथको लिंगो ठड्याउने",
    "Marshi Dhan Diwas (Celebrated in Jumla District": "मार्शी धान दिवस (जुम्ला जिल्लामा मनाइने",

    # Syangja
    "Syang Lasargha Aalamdevi Puja": "स्याङ लसर्घा आलमदेवी पूजा",
    "Syanga Lasargha Aalamdevi Puja": "स्याङ लसर्घा आलमदेवी पूजा",
    "Syangja Lasagra aalamdevi puja": "स्याङ्जा लसग्रा आलमदेवी पूजा",
    "Syangja Lasargha Aalamdevi Puja": "स्याङ्जा लसर्घा आलमदेवी पूजा",
    "Syangja Lasargha Alamdevi Puja": "स्याङ्जा लसर्घा आलमदेवी पूजा",
    "Syanjalasargha Aalamdevi Puja": "स्याङ्जा लसर्घा आलमदेवी पूजा",

    # Yomari Punhi
    "Yomari Punhi": "योमरी पुन्हि",

    # Sukharatri
    "Sukharatri": "सुखरात्री",

    # Chaitedashain
    "Chaitedashain": "चैतेदशैं",

    # Balachaturdashi
    "Bala chaturdashi": "बाला चतुर्दशी",
    "Balachaturdashi": "बालाचतुर्दशी",
    "Balachaturthi": "बाला चतुर्थी",

    # Eid
    "Eid-UI-Fitr": "ईद-उल-फित्र",
    "Eid-Ul-Ajhaa (Bakr Eid)": "ईद-उल-अजहा (बक्र ईद)",
    "Bakr Eid": "बक्र ईद",
    "Ramjan Edul Fikra": "रमजान ईदुल फित्र",

    # Boudha
    "Boudawatar": "बौद्धावतार",
    "Boudhawatar": "बौद्धावतार",

    # Kulayan
    "Kulayan Puja Starts": "कुलायण पूजा सुरु",

    # Places mentioned in context
    "Morang": "मोरङ",
    "Sunsari": "सुनसरी",
    "Siraha & Saptari where celeberated)": "सिराहा र सप्तरीमा मनाइने)",
    "Siraha and Saptari Districts)": "सिराहा र सप्तरी जिल्ला)",
    "Siraha and Saptari jilla haru ma bida)": "सिराहा र सप्तरी जिल्लाहरूमा बिदा)",
    "Hilly and inner Madhes)": "पहाड र भित्री मधेश)",
    "geographical area and location)": "भौगोलिक क्षेत्र र स्थान)",
    "geography and location)": "भूगोल र स्थान)",
    "culture": "संस्कृति",

    # Ethnic groups
    "Kirant": "किरात",
    "Kirant Rai": "किरात राई",
    "Kirant Rai Limbu Jatiko Urvyauli Parba -": "किरात राई लिम्बू जातिको उधौली पर्व -",
    "Limbu": "लिम्बू",
    "Limbu peoples": "लिम्बू जाति",
    "Limbu peoples Urvyauli parba": "लिम्बू जातिको उधौली पर्व",
    "Rai": "राई",
    "Sunuwar": "सुनुवार",

    # Misc
    "Cow": "गाई",
    "Mela": "मेला",
    "Brat": "व्रत",
    "Asan": "आसन",
    "Asan Chaln": "आसन चलन",
    "Asan: Chalan:": "आसन: चलन:",
    "Chaln": "चलन",
    "Bhumiraj": "भूमिराज",

    # Yomari
    "Yomari Punhi": "योमरी पुन्हि",

    # Smartanam Ekadashi
    "smarta haruko aparaa ekadashi brata": "स्मार्तहरुको अपरा एकादशी व्रत",
    "Smartko yogini ekadashi brat": "स्मार्तको योगिनी एकादशी व्रत",
    "Baishnab haruko aparaa ekadashi brata": "वैष्णवहरुको अपरा एकादशी व्रत",
    "Baishnabko yogini ekadashi brat": "वैष्णवको योगिनी एकादशी व्रत",
    "Harisayani Ekadash Brat": "हरिशयनी एकादशी व्रत",
    "Mohini Ekdashi": "मोहिनी एकादशी",
    "Paap mochini Ekadashbrat": "पापमोचिनी एकादशी व्रत",
    "Rama Ekdashi Brat": "रामा एकादशी व्रत",
    "Safala Ekdashi": "सफला एकादशी",
    "Utpatika Ekashi Brat": "उत्पत्तिका एकादशी व्रत",

    # Misc numbers
    "10 Chaturdashi Shradda": "१० चतुर्दशी श्राद्ध",
    "10 Saptami Shradda": "१० सप्तमी श्राद्ध",
    "11 Tritiya Shradda": "११ तृतीया श्राद्ध",
    "13 Dashami Shradda": "१३ दशमी श्राद्ध",
    "13 Panchami Shradda": "१३ पञ्चमी श्राद्ध",
    "13 Tritiya Shradda": "१३ तृतीया श्राद्ध",
    "15 Panchami Shradda": "१५ पञ्चमी श्राद्ध",
    "15 Saptami Shradda": "१५ सप्तमी श्राद्ध",
    "17 Saptami Shradda": "१७ सप्तमी श्राद्ध",
    "18 Darsha Shradda": "१८ दर्श श्राद्ध",
    "18 Dashami Shradda": "१८ दशमी श्राद्ध",
    "19 Nawami Shradda": "१९ नवमी श्राद्ध",
    "20 Dashami Shradda": "२० दशमी श्राद्ध",
    "20 Indrajatra": "२० इन्द्रजात्रा",
    "21 Chaturdashi Shradda": "२१ चतुर्दशी श्राद्ध",
    "23 Snaan Daan Aaunshi": "२३ स्नान दान औंशी",
    "23 Tritiya Shradda": "२३ तृतीया श्राद्ध",
    "24 Chaturdashi Shradda": "२४ चतुर्दशी श्राद्ध",
    "26 Sasthi Shradda": "२६ षष्ठी श्राद्ध",
    "30 Dashami Shradda": "३० दशमी श्राद्ध",
    "6 Tritiya Shradda": "६ तृतीया श्राद्ध",
    "7 Dar khane din": "७ दार खाने दिन",
    "8 Panchami Shradda": "८ पञ्चमी श्राद्ध",

    # Law notes
    "Law and Constitutional Employees)": "कानुन तथा संवैधानिक कर्मचारीहरू)",
    "Law and Constitutional Offices)": "कानुन तथा संवैधानिक कार्यालयहरू)",

    # Mata Tirtha
    "Matatirtha Aaunshi": "माता तीर्थ औंशी",
    "mata tirtha": "माता तीर्थ",
    "Mata Tirtha aaunshi": "माता तीर्थ औंशी",
    "Mata Tirtha Aaunshi": "माता तीर्थ औंशी",

    # Final remaining variations
    "Aama Ko mukh herne din": "आमाको मुख हेर्ने दिन",
    "Amako Mukh herne": "आमाको मुख हेर्ने दिन",
    "Aaunshi": "औंशी",
    "Laxmi Ouja": "लक्ष्मी पूजा",
    "Silachahre:": "शिलाचर्हे:",
    "World Population day": "विश्व जनसंख्या दिवस",
}


def translate_event(event_name: str) -> str:
    """
    Translate an event name from English to Nepali.
    Uses exact matching first, then partial matching for compound names.
    """
    # Check for exact match
    if event_name in EVENT_TRANSLATIONS:
        return EVENT_TRANSLATIONS[event_name]

    # Try partial matching for compound names
    translated = event_name
    for eng, nep in sorted(EVENT_TRANSLATIONS.items(), key=lambda x: -len(x[0])):
        if eng in translated:
            translated = translated.replace(eng, nep)

    # If no translation found, return original (it might already be in transliterated Nepali)
    return translated


def process_calendar_events(input_path: Path, output_path: Path):
    """
    Process the calendar events JSON file and add events_np field.
    """
    with open(input_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # Track untranslated events for review
    untranslated = set()

    for month_key, month_data in data.items():
        if 'days' not in month_data:
            continue

        for day_data in month_data['days']:
            if 'events' not in day_data:
                continue

            events = day_data['events']
            events_np = []

            for event in events:
                translated = translate_event(event)
                events_np.append(translated)

                # Track events that weren't translated
                if translated == event and not any(ord(c) >= 0x0900 and ord(c) <= 0x097F for c in event):
                    untranslated.add(event)

            day_data['events_np'] = events_np

    # Write output
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"Processed calendar events. Output written to {output_path}")

    if untranslated:
        print(f"\nUntranslated events ({len(untranslated)}):")
        for event in sorted(untranslated):
            print(f"  - {event}")


if __name__ == '__main__':
    script_dir = Path(__file__).parent
    input_file = script_dir.parent / 'assets' / 'data' / 'nepali_calendar_events.json'
    output_file = input_file  # Overwrite the same file

    process_calendar_events(input_file, output_file)

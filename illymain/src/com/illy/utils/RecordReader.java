package com.illy.utils;

import com.illy.usecases.CreateFaceTemplateUseCase;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;
import java.util.Properties;

public class RecordReader {

    public void readFromXML(InputStream is) throws XMLStreamException {
        XMLInputFactory inputFactory = XMLInputFactory.newInstance();
        XMLStreamReader reader = null;
        try {
            reader = inputFactory.createXMLStreamReader(is);
            readDocument(reader);
        } finally {
            if (reader != null) {
                reader.close();
            }
        }
    }

    private void readDocument(XMLStreamReader reader) throws XMLStreamException {

        int counter = 0;

        while (reader.hasNext()) {
            int eventType = 0;
            try {
                eventType = reader.next();

                switch (eventType) {
                    case XMLStreamReader.START_ELEMENT:
                        String elementName = reader.getLocalName();
                        if (elementName.equals("row"))
                            readRows(reader);
                        System.out.println("counter: " + counter);
                        counter++;
                        break;
                    case XMLStreamReader.END_ELEMENT:
                        String elementName2 = reader.getLocalName();
                        if (elementName2.equals("row"))
                            ;// readRows(reader);
                        break;
                }
            } catch (RuntimeException ex) {
                String s = "adf";
            }
        }
        System.out.println("counter: " + counter);
        throw new XMLStreamException("Premature end of file");
    }

    public String stripNonValidXMLCharacters(String in) {
        StringBuffer out = new StringBuffer(); // Used to hold the output.
        char current; // Used to reference the current character.

        if (in == null || ("".equals(in))) return ""; // vacancy test.
        for (int i = 0; i < in.length(); i++) {
            current = in.charAt(i); // NOTE: No IndexOutOfBoundsException caught here; it should not happen.
            if ((current == 0x9) ||
                    (current == 0xA) ||
                    (current == 0xD) ||
                    ((current >= 0x20) && (current <= 0xD7FF)) ||
                    ((current >= 0xE000) && (current <= 0xFFFD)) ||
                    ((current >= 0x10000) && (current <= 0x10FFFF)))
                out.append(current);
        }
        return out.toString();
    }

    private void readRows(XMLStreamReader reader) throws XMLStreamException {

        try {

            Record r = new Record();

            while (reader.hasNext()) {

                int eventType = reader.next();
                switch (eventType) {
                    case XMLStreamReader.START_ELEMENT:
                        String elementName = reader.getLocalName();

                        if (elementName.equals("field")) {
                            String attributeName = reader.getAttributeValue(null, "name");

                            if (attributeName.equals("id"))
                                r.id = reader.getElementText();

                            if (attributeName.equals("email"))
                                r.email = reader.getElementText();

                            if (attributeName.equals("email_verified"))
                                r.isEmailVerified = reader.getElementText();

                            if (attributeName.equals("photo"))
                                r.photo = reader.getElementText();

                            if (attributeName.equals("location"))
                                r.location = reader.getElementText();

                            if (attributeName.equals("fbid"))
                                r.fbid = reader.getElementText();

                            if (attributeName.equals("locationId"))
                                r.locationId = reader.getElementText();

                            if (attributeName.equals("sex"))
                                r.sex = reader.getElementText();

                            if (attributeName.equals("dob"))
                                r.dob = reader.getElementText();

                            if (attributeName.equals("firstname"))
                                r.firstname = reader.getElementText();

                            if (attributeName.equals("lastname"))
                                r.lastname = reader.getElementText();


                        }
                        break;
                    case XMLStreamReader.END_ELEMENT:
                        elementName = reader.getLocalName();

                        if (elementName.equals("row")) {

                            Properties props = new Properties();
                            String imageFile = "http://ilooklikeyou.com" + r.photo;
                            props.put(CreateFaceTemplateUseCase.INPUT_IMAGE_FILE_PATH, imageFile);
                            props.put(CreateFaceTemplateUseCase.INPUT_TEMPLATE_STORAGE_S3_BUCKETNAME, "illys3");
                            props.put(CreateFaceTemplateUseCase.INPUT_MEGAMATCHER_SERVER_HOST, "localhost");
                            props.put(CreateFaceTemplateUseCase.INPUT_MEGAMATCHER_SERVER_PORT, "24932");

                            CreateFaceTemplateUseCase useCase = new CreateFaceTemplateUseCase(props);

                            Outcome createTemplateOutcome = useCase.run();

                            if (createTemplateOutcome.isValid()) {
                                String s = "foo bar";
                            }
                            System.out.println(r.toString());

                            if (r.email.equals("danielle.kennedy23@yahoo.co.uk") || r.email.equals("rgc2112@gmail.com")) {

                                r.email = "sdfoo";
                            }

                            return;
                        }
                }
            }
        } finally {

        }
        throw new XMLStreamException("Premature end of file");
    }

}
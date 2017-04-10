package com.illy.usecases.tests;

import com.illy.usecases.CreateFaceTemplateUseCase;
import org.junit.Test;
import java.util.Properties;

import com.illy.utils.Outcome;

public class CreateFaceTemplateUseCaseTest {
    @Test
    public void testRun() {

        Properties props = new Properties();

        CreateFaceTemplateUseCase useCase =  new CreateFaceTemplateUseCase(props);

        Outcome o = useCase.run();
    }
}

package com.illy.usecases.tests;

import com.illy.usecases.ImportUsersPhotosFromCsvUseCase;
import com.illy.utils.Outcome;
import org.junit.Test;

import java.util.Properties;

public class ImportUsersPhotosFromCsvUseCaseTest {
    @Test
    public void testRun() {

        Properties props = new Properties();

        ImportUsersPhotosFromCsvUseCase useCase =  new ImportUsersPhotosFromCsvUseCase(props);

        Outcome o = useCase.run();

        assert(o.isValid());
    }
}

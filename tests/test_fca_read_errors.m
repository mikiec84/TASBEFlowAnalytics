function test_suite = test_fca_read_errors
    TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_fca_read_nofile
    no_file = '';    
    [fcsdat, fcshdr, fcsdatscaled] = fca_read(no_file);
    log = TASBESession.list();
    assertEqual(log{end}.contents{end}.name, 'NoFile');
    assertEqual(fcsdat, []);
    assertEqual(fcshdr, []);
    assertEqual(fcsdatscaled, []);
end

function test_fca_read_wrongfile
    no_file = '';
    wrong_file = '../TASBEFlowAnalytics-Tutorial/example_controls/wrong.fcs';
    [fcsdat, fcshdr, fcsdatscaled] = fca_read(wrong_file);
    log = TASBESession.list();
    assertEqual(log{end}.contents{end}.name, 'NoFile');
    assertEqual(fcsdat, []);
    assertEqual(fcshdr, []);
    assertEqual(fcsdatscaled, []);
end

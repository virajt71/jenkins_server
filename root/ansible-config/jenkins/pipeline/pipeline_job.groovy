pipelineJob('example-pipeline') {
    parameters {
        choiceParam(
            'action',
            ['apply', 'destroy'],
            'Terraform action to execute'
        )
    }
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/virajt71/Entra_ID_Managment.git')
                    }
                    branch('*/develop')
                }
            }
            scriptPath('Jenkinsfile')
        }
    }
}

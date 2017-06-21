<%@ Page Language="C#" AutoEventWireup="true" CodeFile="MenuProposta.aspx.cs" Inherits="MenuProposta" %>

<!DOCTYPE html>
<html>
<head id="Head1" runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=edge; IE=11; IE=10; IE=9; IE=8; IE=7" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Portal Card</title>
    <link rel="stylesheet" type="text/css" href="../../css/bootstrap.min.css" />
    <link rel="stylesheet" type="text/css" href="../../css/bootstrap-theme.min.css" />
    <link rel="stylesheet" type="text/css" href="../../css/sb-admin-2.min.css" />
    <link rel="stylesheet" type="text/css" href="../../css/jquery-ui.min.css" />
    <link rel="stylesheet" type="text/css" href="../../css/metisMenu/metisMenu.min.css" />
    <link rel="stylesheet" type="text/css" href="../../css/font-awesome/css/font-awesome.min.css" />
    <link rel="stylesheet" type="text/css" href="../../css/default.css" />
    <link href="../../css/dataTables/dataTables.bootstrap.css" rel="stylesheet" type="text/css" />
    <link href="../../css/dataTables/dataTables.responsive.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" type="text/css" href="../../css/bootstrap-datetimepicker.css" />
    <link rel="stylesheet" type="text/css" href="../../css/cssProposta.css" />
    <script language="javascript" type="text/javascript" src="../../js/jquery-3.1.1.min.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/jquery.mask.min.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/jquery.maskMoney.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/bootstrap.js"></script>
    <%--<script language="javascript" type="text/javascript" src="../../js/bootstrap-checkbox.min.js"></script>--%>
    <script language="javascript" type="text/javascript" src="../../js/metisMenu/metisMenu.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/sb-admin-2.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/default.js"></script>
    <script src="../../js/dataTables/jquery.dataTables.min.js" type="text/javascript"></script>
    <script src="../../js/dataTables/dataTables.bootstrap.min.js" type="text/javascript"></script>
    <script src="../../js/dataTables/dataTables.responsive.js" type="text/javascript"></script>
    <script type="text/javascript" src="../../Scripts/moment.min.js"></script>
    <script type="text/javascript" src="../../Scripts/moment-with-locales.min.js"></script>
    <script type="text/javascript" src="../../Scripts/bootstrap-datetimepicker.js"></script>
    <script language="javascript" type="text/javascript">

        var TabelaResultado = null;

        $(document).ready(function () {
            CarregaForm();
        });

        function CarregaForm() {

            $('#txtPesquisa').off("keypress").on('keypress', function (e) {
                if (e.which == 13) {
                    if ($("[name=optBusca]:checked").val() == "NOME") {
                        $(this).val(formataNome($(this).val()));
                    }
                    consultaProposta();
                    return false;
                }

                return e.which !== 13;

            });

            $("#txtPesquisa").keypress(function (event) {

                if (event.ctrlKey)
                    return true;

                var busca = $("[name=optBusca]:checked").val();
                if (busca != 'NOME') {
                    return isKeyNumeric(event);
                }

            });

            $("#txtPesquisa").keydown(function (event) {
                var busca = $("[name=optBusca]:checked").val();
                if (busca != 'NOME') {
                    if (!isNumeric($(this).val()))
                        $(this).val('');
                }

            });

            $("#btnBuscar").off("click").on("click", function () {
                consultaProposta();
            });

            // configuramos a máscara para o controle de pesquisa
            var busca = $("[name=optBusca]:checked").val()
            if (busca == 'CPF') {
                $('#txtPesquisa').mask('999.999.999-99', { placeholder: 'CPF do proponente' });
            }
            else if (busca == 'CNPJ') {
                $('#txtPesquisa').mask('99.999.999/9999-99', { placeholder: 'CNPJ do proponente' });
            }
            else if (busca == 'PROPOSTA') {
                $('#txtPesquisa').mask('999999999999999999', { placeholder: 'Número da proposta' });
            }
            else if (busca == 'NOME') {
                $('#txtPesquisa').attr('placeholder', 'Nome do proponente');
                $("#txtPesquisa").unmask();
            }

            $("#txtPesquisa").focusout(function () {
                if ($("#txtPesquisa").val() == "") return;

                var busca = $("[name=optBusca]:checked").val();

                if (busca == 'CPF') {
                    if (!validaCpf($(this).val().trim())) {
                        exibePopover($(this), "CPF inválido");

                        if ($(this).attr('data-required') !== undefined) {
                            if ($(this).attr('data-required') == "" || $(this).attr('data-required').toLowerCase() != "false") {
                                exibeError($(this), true);
                            }
                        }
                    }
                }
                else if (busca == 'CNPJ') {
                    if (!validaCnpj($(this).val().trim())) {
                        exibePopover($(this), "CNPJ inválido");

                        if ($(this).attr('data-required') !== undefined) {
                            if ($(this).attr('data-required') == "" || $(this).attr('data-required').toLowerCase() != "false") {
                                exibeError($(this), true);
                            }
                        }
                    }
                }
                else if (busca == 'NOME') {
                    $(this).val(formataNome($(this).val()));
                }

            });

            // método para carregar o tipo de pesquisa
            $('input[type=radio][name=optBusca]').change(function () {

                $('#divBusca').hide();
                $('#divData').hide();
                $('#divStatus').hide();

                if (this.value == 'CPF') {
                    $('#txtPesquisa').mask('999.999.999-99', { placeholder: 'CPF do proponente' });
                    $('#divBusca').show();

                    $('#txtPesquisa').val('');
                    exibeError($('#txtPesquisa'), false);
                    $('#txtPesquisa').focus();

                }
                else if (this.value == 'CNPJ') {
                    $('#txtPesquisa').mask('99.999.999/9999-99', { placeholder: 'CNPJ do proponente' });
                    $('#divBusca').show();
                    $('#divData').hide();
                    $('#divStatus').hide();

                    $('#txtPesquisa').val('');
                    exibeError($('#txtPesquisa'), false);
                    $('#txtPesquisa').focus();

                }
                else if (this.value == 'PROPOSTA') {
                    $('#txtPesquisa').mask('999999999999999999', { placeholder: 'Número da proposta' });
                    $('#divBusca').show();

                    $('#txtPesquisa').val('');
                    exibeError($('#txtPesquisa'), false);
                    $('#txtPesquisa').focus();

                }
                else if (this.value == 'NOME') {
                    $('#txtPesquisa').attr('placeholder', 'Nome do proponente');
                    $("#txtPesquisa").unmask();
                    $('#divBusca').show();

                    $('#txtPesquisa').val('');
                    exibeError($('#txtPesquisa'), false);
                    $('#txtPesquisa').focus();

                }
                else if (this.value == 'DATA') {
                    $('#divData').show();

                    $('#txtDataInicio').val('');
                    $('#txtDataFim').val('');
                    exibeError($('#txtDataInicio'), false);
                    exibeError($('#txtDataFim'), false);
                    $('#txtDataInicio').focus();

                }
                else if (this.value == 'STATUS') {
                    $('#divStatus').show();

                    $('#ddlStatus').val('');
                    exibeError($('#ddlStatus'), false);
                    $('#ddlStatus').focus();

                }

            });

            //////////////////////////////////////
            var tipoPesquisa = request('TipoPesquisa');
            var valorPesquisa = request('ValorPesquisa');

            if (!isNullOrEmpty(valorPesquisa) && !isNullOrEmpty(tipoPesquisa)) {

                $('#divBusca').hide();
                $('#divData').hide();
                $('#divStatus').hide();

                if (tipoPesquisa == "CPF") {
                    $("input[name=optBusca][id=optCPF]").prop('checked', true);
                    $('#divBusca').show();

                    $('#txtPesquisa').mask('999.999.999-99', { placeholder: 'CPF do proponente' });

                    $("#txtPesquisa").val(valorPesquisa);
                    $('#txtPesquisa').focus();
                    $('#divBusca').show();
                }
                else if (tipoPesquisa == "CNPJ") {
                    $("input[name=optBusca][id=optCNPJ]").prop('checked', true);
                    $('#divBusca').show();

                    $('#txtPesquisa').mask('99.999.999/9999-99', { placeholder: 'CNPJ do proponente' });

                    $("#txtPesquisa").val(valorPesquisa);
                    $('#txtPesquisa').focus();

                }
                else if (tipoPesquisa == "STATUS") {
                    $("input[name=optBusca][id=optStatus]").prop('checked', true);
                    $('#divStatus').show();

                    $('#ddlStatus').val(valorPesquisa);
                    $('#txtDataInicio').focus();

                }
                else if (tipoPesquisa == "DATA") {
                    $("input[name=optBusca][id=optData]").prop('checked', true);
                    $('#divData').show();

                    $('#txtDataInicio').val('');
                    $('#txtDataFim').val('');
                    $('#txtDataInicio').focus();

                }
                else if (tipoPesquisa == "PROPOSTA") {
                    $("input[name=optBusca][id=optProposta]").prop('checked', true);
                    $('#divBusca').show();

                    $('#txtPesquisa').attr('placeholder', 'Número da proposta');
                    $("#txtPesquisa").unmask();

                    $("#txtPesquisa").val(valorPesquisa);
                    $('#txtPesquisa').focus();

                }
                else if (tipoPesquisa == "NOME") {
                    $("input[name=optBusca][id=optNome]").prop('checked', true);
                    $('#divBusca').show();

                    $('#txtPesquisa').attr('placeholder', 'Nome do proponente');
                    $("#txtPesquisa").unmask();

                    $("#txtPesquisa").val(valorPesquisa);
                    $('#txtPesquisa').focus();

                }

                consultaProposta();

            }
            else {
                $("input[name=optBusca][id=optCPF]").prop('checked', true);
                $('#txtPesquisa').mask('999.999.999-99', { placeholder: 'CPF do proponente' });

                $("#txtPesquisa").val(valorPesquisa);
                $('#txtPesquisa').focus();
                $('#divBusca').show();
            }

            //////////////////////////////////////

            $(".loading").fadeOut("slow");

        }

        function consultaProposta() {

            try {

                if (ValidaPesquisa()) {

                    $(".loading").fadeIn("slow");
                    $("#divListaResultado").slideUp();

                    var tipoPesquisa = $("[name=optBusca]:checked").val();
                    var valorPesquisa = "";

                    if (tipoPesquisa == 'DATA') {
                        valorPesquisa = $('#txtDataInicio').val() + ";" + $('#txtDataFim').val()
                    }
                    else if (tipoPesquisa == 'STATUS') {
                        valorPesquisa = $('#ddlStatus').val();
                    }
                    else {
                        valorPesquisa = $('#txtPesquisa').val();
                    }

                    var param = JSON.stringify({
                        valorPesquisa: valorPesquisa,
                        tipoPesquisa: tipoPesquisa
                    });

                    setTimeout(function () {

                        $.ajax({
                            type: "POST",
                            contentType: "application/json; charset=utf-8",
                            url: 'MenuProposta.aspx/ConsultaProposta',
                            data: param,
                            dataType: "json",
                            async: false,
                            success: function (response) {

                                var jsonResult = response.d;

                                if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {
                                    $("#table-resultado tbody tr").remove();

                                    $(".loading").fadeOut("slow");

                                    carregaProposta(jsonResult.Resultado);
                                    $("#divListaResultado").slideDown();
                                }
                                else if (!jsonResult.Resposta && jsonResult.Mensagem == "SessaoFinalizada") {
                                    window.location.href = "../../SessaoFinalizada.aspx";
                                }
                                else if (!jsonResult.Resposta && jsonResult.Mensagem == "ValidaDados") {
                                    $(".loading").fadeOut("slow");
                                    $('#modalError').modal('show');
                                }
                                else if (jsonResult.Erro) {
                                    console.log(jsonResult.Mensagem);
                                    window.location.href = "../../Erro.aspx";
                                }
                                else {
                                    $(".loading").fadeOut("slow");
                                    setTimeout(function () {
                                        exibeCampoObrigatorio($('#txtPesquisa'), "Cliente não encontrado!");
                                    }, 500);
                                }

                            },
                            error: function (response) {
                                $("#table-resultado tbody tr").remove();

                                $(".loading").fadeOut("slow");
                                //$('#modalError').modal('show');
                                window.location.href = "../../Erro.aspx";

                            }
                        })

                    }, 500);

                }

                $(".loading").fadeOut("slow");

            }
            catch (Erro) {
                $(".loading").fadeOut("slow");
                $("#MensagemErro").text('Erro ao validar os dados do cliente!');
                $("#modalErro").modal("show");
                return false;
            }
        }

        function carregaProposta_old(proposta) {

            if (proposta != null) {
                var html = "";

                for (i in proposta) {

                    var nome = "";
                    var cpf_cnpj = "";

                    if (proposta[i].PessoaFisica != null) {
                        nome = proposta[i].PessoaFisica.NomeCompleto;
                        cpf_cnpj = proposta[i].PessoaFisica.CPF;
                        cpf_cnpj = cpf_cnpj.substring(0, 3) + "." + cpf_cnpj.substring(3, 6) + "." + cpf_cnpj.substring(6, 9) + "-" + cpf_cnpj.substring(9)
                    }
                    else {
                        nome = proposta[i].PessoaJuridica.NomeFantasia;
                        cpf_cnpj = proposta[i].PessoaJuridica.CNPJPJ;
                        cpf_cnpj = cpf_cnpj.substring(0, 2) + "." + cpf_cnpj.substring(2, 5) + "." + cpf_cnpj.substring(5, 8) + "/" + cpf_cnpj.substring(8, 12) + "-" + cpf_cnpj.substring(12)
                    }

                    html = "<tr>";
                    html += "   <td style='vertical-align:middle'>" + cpf_cnpj + "</td>";
                    html += "   <td style='vertical-align:middle'>" + nome + "</td>";

                    var bandeira = proposta[i].Bandeira;
                    html += "   <td style='vertical-align:middle; text-align:center'>" + bandeira + "</td>";

                    var data = new Date(parseInt(proposta[i].DataProposta.replace('/Date(', '')));
                    data = toLocaleDateString(data);
                    html += "   <td style='vertical-align:middle; text-align:center'>" + data + "</td>";

                    var status = proposta[i].HistoricoProposta.Status

                    if (status == "Proposta aprovada")
                        status = "<span class='color-green' data-toggle='tooltip' data-placement='top' title='" + proposta[i].HistoricoProposta.Situacao + "'>" + status + "</span>";
                    else if (status == "Proposta em análise")
                        status = "<span class='color-blue' data-toggle='tooltip' data-placement='top' title='" + proposta[i].HistoricoProposta.Situacao + "'>" + status + "</span>";
                    else if (status == "Proposta recusada")
                        status = "<span class='color-red' data-toggle='tooltip' data-placement='top' title='" + proposta[i].HistoricoProposta.Situacao + "'>" + status + "</span>";
                    else if (status == "Proposta reprovada")
                        status = "<span class='color-red' data-toggle='tooltip' data-placement='top' title='" + proposta[i].HistoricoProposta.Situacao + "'>" + status + "</span>";

                    html += "   <td style='vertical-align:middle; text-align:center'>" + status + "</td>";

                    html += "   <td style='vertical-align:middle; text-align:center'><a href='Proposta.aspx?conta=" + proposta[i].NumeroProposta + "' class='action btn btn-outline btn-primary btn-xs glyphicon glyphicon-edit' data-toggle='tooltip' data-placement='top' title='atualizar proposta' /> </td>";

                    html += "</tr>";

                    var table = $("#table-resultado tbody");
                    table.append(html);

                    $(".action").click(function (event) {
                        $(".loading").fadeIn("slow");
                        //setTimeout(function () {
                        //    $(".loading").fadeOut("slow");
                        //}, 200);

                        $(this).blur();
                    });
                }
            }

        }

        function carregaProposta(proposta) {

            var row = [];
            TabelaResultado.clear();

            if (proposta != null) {

                if (proposta.length > 10) {

                    TabelaResultado.destroy();
                    configuraGrid(true);
                }

                var html = "";

                for (i in proposta) {

                    var cpf_cnpj = "";
                    var nome = "";
                    var bandeira = "";
                    var status = "";
                    var data = null;
                    var acao = "";

                    if (proposta[i].PessoaFisica != null) {
                        nome = proposta[i].PessoaFisica.NomeCompleto;
                        cpf_cnpj = proposta[i].PessoaFisica.CPF;
                        cpf_cnpj = cpf_cnpj.substring(0, 3) + "." + cpf_cnpj.substring(3, 6) + "." + cpf_cnpj.substring(6, 9) + "-" + cpf_cnpj.substring(9)
                    }
                    else {
                        nome = proposta[i].PessoaJuridica.NomeFantasia;
                        cpf_cnpj = proposta[i].PessoaJuridica.CNPJPJ;
                        cpf_cnpj = cpf_cnpj.substring(0, 2) + "." + cpf_cnpj.substring(2, 5) + "." + cpf_cnpj.substring(5, 8) + "/" + cpf_cnpj.substring(8, 12) + "-" + cpf_cnpj.substring(12)
                    }

                    bandeira = "<center>" + proposta[i].Bandeira + "</center>";
                    data = new Date(parseInt(proposta[i].DataProposta.replace('/Date(', '')));
                    data = "<center>" + toLocaleDateString(data) + "</center>";

                    status = proposta[i].HistoricoProposta.Status
                    if (status == "Proposta aprovada")
                        status = "<center><span class='color-green' data-toggle='tooltip' data-placement='top' title='" + proposta[i].HistoricoProposta.Situacao + "'>" + status + "</span></center>";
                    else if (status == "Proposta em análise")
                        status = "<center><span class='color-blue' data-toggle='tooltip' data-placement='top' title='" + proposta[i].HistoricoProposta.Situacao + "'>" + status + "</span></center>";
                    else if (status == "Proposta recusada")
                        status = "<center><span class='color-red' data-toggle='tooltip' data-placement='top' title='" + proposta[i].HistoricoProposta.Situacao + "'>" + status + "</span></center>";
                    else if (status == "Proposta reprovada")
                        status = "<center><span class='color-red' data-toggle='tooltip' data-placement='top' title='" + proposta[i].HistoricoProposta.Situacao + "'>" + status + "</span></center>";

                    acao = "<center><a href='Proposta.aspx?conta=" + proposta[i].NumeroProposta + "' class='action btn btn-outline btn-primary btn-xs glyphicon glyphicon-edit' data-toggle='tooltip' data-placement='top' title='atualizar proposta' /> </center>"

                    row = [
                        cpf_cnpj,
                        nome,
                        bandeira,
                        data,
                        status,
                        acao
                    ]

                    TabelaResultado.row.add(row);

                }

                TabelaResultado.draw();
                return;

            }

        }

        function ValidaPesquisa() {

            var busca = $("[name=optBusca]:checked").val();

            if (busca == 'CPF') {

                if ($('#txtPesquisa').val() == "") {
                    exibeError($('#txtPesquisa'), true);
                    $('#txtPesquisa').focus();
                    return false;
                }

                if (!validaCpf($('#txtPesquisa').val().trim())) {
                    setTimeout(function () {
                        exibeCampoObrigatorio($('#txtPesquisa'), "CPF inválido!");
                        $('#txtPesquisa').focus();
                    }, 200);
                    return false;
                }
            }
            else if (busca == 'CNPJ') {
                if ($('#txtPesquisa').val() == "") {
                    exibeError($('#txtPesquisa'), true);
                    $('#txtPesquisa').focus();
                    return false;
                }

                if (!validaCnpj($('#txtPesquisa').val().trim())) {
                    setTimeout(function () {
                        exibeCampoObrigatorio($('#txtPesquisa'), "CNPJ inválido!");
                        $('#txtPesquisa').focus();
                    }, 200);
                    return false;
                }
            }
            else if (busca == 'NUMERO') {
                if ($('#txtPesquisa').val() == "") {
                    exibeError($('#txtPesquisa'), true);
                    $('#txtPesquisa').focus();
                    return false;
                }

            }
            else if (busca == 'NOME') {
                if ($('#txtPesquisa').val() == "") {
                    exibeError($('#txtPesquisa'), true);
                    $('#txtPesquisa').focus();
                    return false;
                }

                if ($('#txtPesquisa').val().trim().length < 3) {
                    setTimeout(function () {
                        exibeCampoObrigatorio($('#txtPesquisa'), "Informe o mínimo 3 caracteres!");
                        $('#txtPesquisa').focus();
                    }, 200);
                    return false;
                }
            }
            else if (busca == 'DATA') {
                if ($('#txtDataInicio').val() == "") {
                    exibeError($('#txtDataInicio'), true);
                    $('#txtDataInicio').focus();
                    return false;
                }
                if ($('#txtDataFim').val() == "") {
                    exibeError($('#txtDataFim'), true);
                    $('#txtDataFim').focus();
                    return false;
                }

                if (!validaData($('#txtDataInicio').val().trim())) {
                    setTimeout(function () {
                        exibeCampoObrigatorio($('#txtDataInicio'), "Data início inválida!");
                        $('#txtDataInicio').focus();
                    }, 200);
                    return false;
                }
                if (!validaData($('#txtDataFim').val().trim())) {
                    setTimeout(function () {
                        exibeCampoObrigatorio($('#txtDataFim'), "Data fim inválida!");
                        $('#txtDataFim').focus();
                    }, 200);
                    return false;
                }

                if (!comparaData($('#txtDataInicio').val().trim(), $('#txtDataFim').val().trim())) {
                    setTimeout(function () {
                        exibeCampoObrigatorio($('#txtDataInicio'), "A data incial não pode ser maior que a data final!");
                        $('#txtDataInicio').focus();
                    }, 200);
                    return false;
                }

            }
            else if (busca == 'STATUS') {
                if ($('#ddlStatus')[0].selectedIndex < 1) {
                    setTimeout(function () {
                        exibeError($('#ddlStatus'), true);
                        $('#ddlStatus').focus();
                    }, 200);
                    return false;
                }
            }

            $(".loading").fadeIn("slow");
            return true;
        }

        function configuraGrid(paginacao) {

            if (paginacao === undefined)
                paginacao = false

            TabelaResultado = $('#table-resultado').DataTable({
                responsive: true,
                searching: paginacao,
                lengthChange: paginacao,
                paging: paginacao,
                ordering: paginacao,
                info: paginacao,
                language: {
                    info: "",
                    infoFiltered: "",
                    infoEmpty: "",
                    infoPostFix: "",
                    thousands: ".",
                    loadingRecords: "Carregando...",
                    processing: "Processando...",
                    search: "Pesquisa:",
                    lengthMenu: "",
                    zeroRecords: "Sem resultados para esta pesquisa",
                    paginate: {
                        first: 'Primeiro',
                        previous: 'Anterior',
                        next: 'Próximo',
                        last: 'Último'
                    },
                    aria: {
                        paginate: {
                            first: 'Primeiro',
                            previous: 'Anterior',
                            next: 'Proximo',
                            last: 'Último'
                        }
                    }
                },
                columns: [
                    null,
                    null,
                    null,
                    null,
                    null,
                    { "orderable": false }
                ]

            });

            if (TabelaResultado === null)
                alert('fdsfasdfs');

        }

        function configuraCalendario() {

            $('#datetimeDataInicio,#datetimeDataFim').datetimepicker({
                format: 'DD/MM/YYYY',
                locale: 'pt-br'
            });

            $("#datetimeDataInicio").on("dp.change", function (e) {
                $('#datetimeDataFim').data("DateTimePicker").minDate(e.date);
            });
            $("#datetimeDataFim").on("dp.change", function (e) {
                $('#datetimeDataInicio').data("DateTimePicker").maxDate(e.date);
            });

        }

    </script>
</head>
<body class="fadeIn">
    <form id="form1" autocomplete="off" runat="server">
    <asp:ScriptManager runat="server">
    </asp:ScriptManager>
    <asp:HiddenField ID="hdnOperacao" runat="server" Value="" />
    <asp:HiddenField ID="hdnNumeroCartao" runat="server" Value="" />
    <asp:HiddenField ID="hdnMensagem" runat="server" Value="" />
    <div class="container">
        <div class="content">
            <div class="row">
                <div class="col-md-12">
                    <h3 class="page-header">
                        Proposta</h3>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel-body">
                        <div class="row">
                            <div class="panel panel-default">
                                <div class="panel-heading panel-font">
                                    Consulta Propostas
                                </div>
                                <div class="panel-body">
                                    <div class="form-group">
                                        <label class="radio-inline">
                                            <input runat="server" type="radio" name="optBusca" id="optCPF" value="CPF" />CPF
                                        </label>
                                        <label class="radio-inline">
                                            <input type="radio" name="optBusca" id="optCNPJ" value="CNPJ" />CNPJ
                                        </label>
                                        <%--<label class="radio-inline">
                                            <input runat="server" type="radio" name="optBusca" id="optProposta" value="NUMERO" />Proposta
                                        </label>--%>
                                        <label class="radio-inline">
                                            <input runat="server" type="radio" name="optBusca" id="optNome" value="NOME" />Nome
                                        </label>
                                        <label class="radio-inline">
                                            <input runat="server" type="radio" name="optBusca" id="optData" value="DATA" />Data
                                        </label>
                                        <label class="radio-inline">
                                            <input runat="server" type="radio" name="optBusca" id="optStatus" value="STATUS" />Situação
                                        </label>
                                    </div>
                                    <div class="row">
                                        <div id="divBusca" class="col-md-4">
                                            <div class="form-group">
                                                <asp:TextBox ID="txtPesquisa" runat="server" Text="" MaxLength="50" data-required="true"
                                                    CssClass="form-control"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div id="divData" class="col-md-4 display-none">
                                            <div class="form-inline">
                                                <div class='form-group input-group date' style="width: 150px" id='datetimeDataInicio'>
                                                    <asp:TextBox ID="txtDataInicio" runat="server" MaxLength="9" placeholder="Data inicio"
                                                        CssClass="form-control input-date" data-required="true"></asp:TextBox>
                                                    <span class="input-group-addon"><i class="fa fa-calendar"></i></span>
                                                </div>
                                                &nbsp;até&nbsp;
                                                <div class='form-group input-group date' style="width: 150px" id='datetimeDataFim'>
                                                    <asp:TextBox ID="txtDataFim" runat="server" MaxLength="9" placeholder="Data fim"
                                                        CssClass="form-control input-date" data-required="true"></asp:TextBox>
                                                    <span class="input-group-addon"><i class="fa fa-calendar"></i></span>
                                                </div>
                                            </div>
                                        </div>
                                        <div id="divStatus" class="col-md-4 display-none">
                                            <div class="form-group">
                                                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control" Width="250"
                                                    data-required="true">
                                                    <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                                    <asp:ListItem Text="Proposta em análise" Value="1" />
                                                    <asp:ListItem Text="Proposta recusada" Value="2" />
                                                    <asp:ListItem Text="Proposta aprovado" Value="3" />
                                                    <asp:ListItem Text="Proposta reprovada" Value="4" />
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-group">
                                                <button type="button" id="btnBuscar" usesubmitbehavior="False" class="btn btn-default">
                                                    <i class="fa fa-search"></i>Buscar</button>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-12">
                                            <div id="divListaResultado" class="row display-none">
                                                <div class="col-md-12 bs-glyphicons">
                                                    <hr />
                                                    <table width="100%" class="table table-striped table-hover" id="table-resultado">
                                                        <thead>
                                                            <tr>
                                                                <th style="width: 130px">
                                                                    CPF/CNPJ
                                                                </th>
                                                                <th style="width: 200px">
                                                                    Nome
                                                                </th>
                                                                <th style="width: 100px; text-align: center">
                                                                    Bandeira
                                                                </th>
                                                                <th style="width: 100px; text-align: center">
                                                                    Data Proposta
                                                                </th>
                                                                <th style="width: 100px; text-align: center">
                                                                    Situação
                                                                </th>
                                                                <th style="width: 100px; text-align: center">
                                                                    Ações
                                                                </th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <%--<tr><td style='vertical-align:middle'>082.475.507-33</td>   <td style='vertical-align:middle'>João Ribeiro</td>   <td style='vertical-align:middle; text-align:center'>MasterCard</td>   <td style='vertical-align:middle; text-align:center'>31/05/2017</td>   <td style='vertical-align:middle; text-align:center'><span class='color-blue' data-toggle='tooltip' data-placement='top' title='Aguardando analise do backoffice'>Proposta em análise</span></td>   <td style='vertical-align:middle; text-align:center'><a href='Proposta.aspx?conta=16' class='action btn btn-outline btn-primary btn-xs glyphicon glyphicon-edit' data-toggle='tooltip' data-placement='top' title='atualizar proposta' /> </td></tr>--%>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- mensagem -->
        <div class="modal fade alert" id="modalMensagem" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
            aria-hidden="true">
            <div class="modal-dialog alert-info" style="width: 450px">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                            &times;</button>
                        <h4 class="modal-title" id="myModalLabel">
                            Proposta Cliente</h4>
                    </div>
                    <div class="modal-body align-center" style="font-size: 18px !important;" id="MensagemSucesso">
                        Operação realizada com sucesso
                        <br />
                    </div>
                    <div class="modal-body align-center display-none" id="divMensagemNumeroCartao">
                        <h4>
                            <span class="text-warning" style="color: #8a6d3b !important; font-size: 18px !important;"
                                id="MensagemNumeroCartao"></span>
                        </h4>
                    </div>
                    <div class="modal-footer">
                        <button id="btnOk" type="button" class="btn btn-primary center-block" data-dismiss="modal">
                            OK</button>
                    </div>
                </div>
            </div>
        </div>
        <div class="modal fade alert" id="modalErro" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
            aria-hidden="true">
            <div class="modal-dialog alert-danger" style="width: 450px">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                            &times;</button>
                        <h4 class="modal-title">
                            Proposta Cliente</h4>
                    </div>
                    <div class="modal-body align-center" style="font-size: 18px !important;" id="MensagemErro">
                        Erro ao realizar operação!
                    </div>
                    <div class="modal-footer">
                        <button id="Button1" type="button" class="btn btn-danger center-block" data-dismiss="modal">
                            OK</button>
                    </div>
                </div>
            </div>
        </div>
        <div class="loading">
        </div>
    </div>
    </form>
</body>
<script type="text/javascript">
    $(function () {

        configuraGrid();

        configuraCalendario();

    });
</script>
<script language="javascript" type="text/javascript">
    var operacao = $('[id$=hdnOperacao]').val();
    var mensagem = $('[id$=hdnMensagem]').val();

    if (operacao == "Sucesso") {
        var modal = $("#modalMensagem");
        var modalMensagem = $("#MensagemSucesso");

        if ($('#modalMensagem', window.parent.document).length == 1) {
            modal = $('#modalMensagem', window.parent.document);
        }

        modalMensagem.text(mensagem);
        modal.modal("show");

    }
    else if (operacao == "Erro") {
        if ($('#modalErro', window.parent.document).length == 1) {
            $('#modalErro', window.parent.document).modal("show");
        }
        else {
            $("#modalErro").modal("show");
        }
    }

    $('[id$=hdnOperacao]').val('');
    $('[id$=hdnMensagem]').val('');
    

</script>
</html>

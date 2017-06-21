<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeFile="Adicional.aspx.cs"
    Inherits="Adicional" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
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

    <link rel="stylesheet" type="text/css" href="../../css/cssAdicional.css" />

    <%--<script language="javascript" type="text/javascript" src="../../js/jquery-1.9.1.js"></script>--%>
    <script language="javascript" type="text/javascript" src="../../js/jquery-3.1.1.min.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/jquery.mask.min.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/jquery.maskMoney.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/bootstrap.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/metisMenu/metisMenu.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/sb-admin-2.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/default.js"></script>
    <script language="javascript" type="text/javascript">

        var OPERACAO = $('input#hdnOperacao').val();
        var USUARIO = $('input#hdnUsuario').val();

        $(document).ready(function () {

            $('#btnVoltar').click(function () {
                $(".loading").fadeIn("slow");
            });

            $('#txtCpf').focusout(function (e) {
                if ($('#txtCpf').val().trim() != "") {
                    var cpf = $('#txtCpf').val();
                    cpf = cpf.replace('.', '').replace('.', '');
                    cpf = cpf.replace('-', '');

                    var titular = $('input#hdnCpfTitular').val();

                    if (titular == cpf) {
                        exibeCampoObrigatorio($('#txtCpf'), "O CPF do titular não pode ser um adicional");
                    }
                    else {

                        if (!validaAdicional($('#txtCpf').val().trim())) {
                            exibeCampoObrigatorio($('#txtCpf'), "Adicional já cadastrado");
                        }
                    }
                }
            });


            $("#txtFaixaIniBloqExt, #txtFaixaFimBloqExt").keyup(function () {
                exibeError($('#txtFaixaIniBloqExt'), false);
                exibeError($('#txtFaixaFimBloqExt'), false);
            });

            $("#txtNomeCartao").focusout(function (event) {
                $(this).val(removerAcentos($(this).val()));
            });

            $("#ddlNumeroCartaoTitular").change(function () {

                if ($(this).val() == "") {
                    $('#divLimitesProduto').slideUp();
                    $("#table-limites tbody tr").remove();
                    $("#txtLimiteProduto").val(" - ");
                    return;
                }

                $('input#hdnCodCartaoTitular').val($(this).val());

                var listaContas = $('input#hdnCodConta').val();
                contas = $.parseJSON(listaContas);

                var listaProdutos = $('input#hdnCodProdutoCartao').val();
                produtos = $.parseJSON(listaProdutos);

                var listaLimites = $('input#hdnLimiteProduto').val();
                limites = $.parseJSON(listaLimites);

                if (!isNullOrEmpty(limites[$(this).val()])) {
                    $("#txtLimiteProduto").val(limites[$(this).val()]);

                    carregaListaLimiteProduto(contas[$(this).val()], produtos[$(this).val()], 0);
                }
                else {
                    $("#txtLimiteProduto").val('');
                    $('#divLimitesProduto').slideUp();
                    $("#table-limites tbody tr").remove();
                }

                if ($('#txtCpf').val() != "") {
                    validaAdicional($('#txtCpf').val());
                }

            });

            //$("#ddlStatusCartao").change(function () {

            //    var valor = $('#ddlStatusCartao option:selected').text();
            //    $("#ddlTipoBloqueio ").val('')

            //    if (valor == "Bloqueado") {
            //        //$("#divTipoBloqueio ").show();
            //        $('#divTipoBloqueio').fadeIn(500)
            //        $("#ddlTipoBloqueio ").focus();
            //    }
            //    else {
            //        $('#divTipoBloqueio').fadeOut(500)
            //    }

            //    exibeError($('#ddlStatusCartao'), false);

            //});

            $("#ddlBloqueadoExterior").change(function () {
                var valor = $('#ddlBloqueadoExterior option:selected').val();

                if (valor == "0") {
                    $('#divFaixaIniBloqExt').fadeIn("slow");
                    $('#divFaixaFimBloqExt').fadeIn("slow");
                    $("#txtFaixaIniBloqExt").focus();
                }
                else {
                    $('#divFaixaIniBloqExt').fadeOut("slow");
                    $('#divFaixaFimBloqExt').fadeOut("slow");
                    $('#txtFaixaIniBloqExt').val('');
                    $('#txtFaixaFimBloqExt').val('');
                }

                exibeError($('#ddlBloqueadoExterior'), false);

            });

        });

        function validaAdicional(cpf, asynctask) {
            var ret = true;
            cpf = cpf.replace('.', '').replace('.', '');
            cpf = cpf.replace('-', '');
            cpf = cpf.replace('/', '');

            var codCartaoTitular = $('input#hdnCodCartaoTitular').val();
            var titular = $('input#hdnCpfTitular').val();
            var cpfAdicional = $('input#hdnCpfAdicional').val();

            if (titular == cpf)
                return false;

            if (asynctask === undefined)
                asynctask = true;

            if (codCartaoTitular == "")
                return ret;

            if (cpfAdicional == cpf)
                return ret;

            var param = JSON.stringify({
                codCartaoTitular: codCartaoTitular,
                cpfAdicional: cpf
            });

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Adicional.aspx/AdicionalExiste',
                data: param,
                dataType: "json",
                async: asynctask,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult) {
                        ret = false;
                        if (asynctask) {
                            exibeCampoObrigatorio($('#txtCpf'), "Cliente já cadastrado");
                        }
                    }

                },
                failure: function (response) {
                    //$.parseJSON(response.responseText).Message
                    exibeError($('#txtCpf'), true);
                    ret = false
                },
                error: function (response) {
                    //$.parseJSON(response.responseText).Message
                    exibeError($('#txtCpf'), true);
                    ret = false
                }
            });

            return ret;

        }

        function carregaListaLimiteProduto(codConta, codProduto, codAdicional) {
            $('#divLimitesProduto').slideUp();
            $("#table-limites tbody tr").remove();

            var param = JSON.stringify({
                codConta: codConta,
                codProduto: codProduto,
                codAdicional: codAdicional
            });

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Adicional.aspx/ObterDadosLimiteProduto',
                data: param,
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult != null && jsonResult.length > 0) {

                        $.each(jsonResult, function (index, item) {
                            item.ValorLimite = "";

                            var html = '' +
                            "<tr>" +
                                "<th style='width: 200px; text-align:right; padding-top:15px; font-weight:normal'>" +
                                "<span> nomeLimite: </span>" +
                                "</th>" +
                                "<th style='font-weight:normal'><div class='form-group'><div class='input-group'><span class='input-group-addon'>codTipoValorLimite</span>" +
                                    "<input type=text id='valorLimite' value='dadosLimite' data-cod_limite='codLimite' data-cod_tipo_limite='codTipoLimite' data-cod_conta='codConta' data-cod_produto='codProduto' maxlength='10' class='form-control' placeholder='Valor' style='width:80px;'/><span id='infoItemLimite' style='width:100%' class='input-group-addon align-left'>R$ 0,00</span>" +
                                "</div></div></th>" +
                            "</tr>";

                            html = html.replace('codTipoValorLimite', '%')

                            html = html.replace('nomeLimite', item.NomeLimite)
                                       .replace('codLimite', item.CodLimite)
                                       .replace('dadosLimite', item.ValorLimite)
                                       .replace('codTipoLimite', item.CodTipoLimite)
                                       .replace('codConta', codConta)
                                       .replace('codProduto', codProduto)
                                       .replace('valorLimite', 'valorLimite' + item.CodTipoLimite)
                                       .replace('infoItemLimite', 'infoItemLimite' + item.CodTipoLimite);

                            var table = $("#table-limites tbody");
                            table.append(html);

                            $('[id*=valorLimite]').unmask();
                            $('[id*=valorLimite]').mask('999', { placeholder: 'Valor' });

                        });

                        $('[id*=valorLimite]').focusout(function (e) {
                            if ($(this).val().trim() != "") {
                                $(this).val(parseInt($(this).val()));
                            }
                        });


                        $('[id*=valorLimite]').keyup(function (e) {
                            exibeError($(this), false);

                            var limites = $('[id*=valorLimite]');
                            for (var i = 0; i < limites.length; i++) {
                                var item = $(limites[i]);
                                if (item.val().trim() != "") {
                                    exibeError(item, false);
                                }
                            }

                            if ($('#txtLimiteProduto').val().trim() != "") {
                                exibeError($('#txtLimiteProduto'), false);
                            }

                            //var id = $(this).context.id.replace('valorLimite', '');
                            var id = $(this)[0].id.replace('valorLimite', '');

                            var totalProduto = 0.0;
                            if ($('#txtLimiteProduto').val().trim() != "")
                                totalProduto = retornaFloat($('#txtLimiteProduto').val());

                            var valor = totalProduto * $(this).val() / 100;
                            $('#infoItemLimite' + id).text('R$ ' + retornaValor(valor));

                        });

                        $("[id*=valorLimite]").keypress(function (event) {
                            var code = event.charCode || event.keyCode;
                            if (isKeyNumeric(event)) {
                                var value = this.value + event.key;
                                if (this.selectionStart == 0)
                                    value = event.key + this.value.toString();

                                if (value > 100)
                                    return false;
                            }
                            else
                                return false;
                        });

                        $('#txtLimiteProduto').keyup(function (e) {
                            exibeError($(this), false);

                            var limites = $('[id*=valorLimite]');
                            for (var i = 0; i < limites.length; i++) {
                                var item = $(limites[i]);
                                if (item.val().trim() != "") {
                                    exibeError(item, false);
                                }
                            }

                            calculaLimites();

                        });

                        calculaLimites();

                        if ($("#lblOperacao").text().indexOf("Consulta") > -1) {
                            var limites = $('[id*=valorLimite]');
                            for (var i = 0; i < limites.length; i++) {
                                var item = $(limites[i]);
                                item.attr("disabled", "disabled");
                            }
                        }

                        $('#divLimitesProduto').slideDown();

                    };
                }
            });
        }

        function calculaLimites() {

            var totalProduto = 0.0;
            var totalLimitesProduto = 0.0;

            if ($('#txtLimiteProduto').val().trim() != "")
                totalProduto = retornaFloat($('#txtLimiteProduto').val());

            var limites = $('[id*=valorLimite]');

            for (var i = 0; i < limites.length; i++) {
                var item = $(limites[i]);

                if (item.val().trim() != "") {

                    var id = item[0].id.replace('valorLimite', '');
                    var valor = totalProduto * item.val() / 100;

                    $('#infoItemLimite' + id).text('R$ ' + retornaValor(valor));

                }
            }
        }

        function carregaStatusCartao() {

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Adicional.aspx/ObterListaStatusCartao',
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        $('#ddlStatusCartao').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));
                        $.each(jsonResult.Resultado, function (index, item) {
                            $('#ddlStatusCartao').append($('<option>', { value: item.Valor, text: item.Nome }, '</option>'));

                        })

                        $('#ddlStatusCartao').val('2'); // "Bloqueado"
                        $('#ddlStatusCartao').attr("disabled", "disabled");

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
                        exibeError($('#ddlStatusCartao'), true);
                    }

                },
                error: function (response) {
                    //$("#modalErro").modal("show");
                    exibeError($('#ddlStatusCartao'), true);
                    window.location.href = "../../Erro.aspx";
                }
            });

        }

        function carregaTipoBloqueioCartao() {

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Adicional.aspx/ObterListaTipoBloqueioCartao',
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        $('#ddlTipoBloqueio').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));
                        $.each(jsonResult.Resultado, function (index, item) {
                            $('#ddlTipoBloqueio').append($('<option>', { value: item.Valor, text: item.Nome }, '</option>'));

                        })

                        $('#divTipoBloqueio').fadeIn(500)
                        $('#ddlTipoBloqueio').val('2'); // "Entrega"
                        $('#ddlTipoBloqueio').attr("disabled", "disabled");


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
                        exibeError($('#ddlTipoBloqueio'), true);
                    }

                },
                error: function (response) {
                    //$("#modalErro").modal("show");
                    exibeError($('#ddlTipoBloqueio'), true);
                    window.location.href = "../../Erro.aspx";
                }
            });

        }

        function carregaListaTipoGrauParentesco() {

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Adicional.aspx/ObterListaTipoParentesco',
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        //$('#ddlParentesco').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));

                        $.each(jsonResult.Resultado, function (index, item) {
                            $('#ddlParentesco').append($('<option>', { value: item.Valor, text: item.Nome }, '</option>'));
                        })
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
                        exibeError($('#ddlParentesco'), true);
                    }
                },
                error: function (response) {
                    //$("#modalErro").modal("show");
                    exibeError($('#ddlParentesco'), true);
                    window.location.href = "../../Erro.aspx";
                }
            });

        }

        function carregaListaEscolaridade() {

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Adicional.aspx/ObterListaEscolaridade',
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        //$('#ddlEscolaridade').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));
                        $.each(jsonResult.Resultado, function (index, item) {
                            $('#ddlEscolaridade').append($('<option>', { value: item.Valor, text: item.Nome }, '</option>'));
                        })
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
                        exibeError($('#ddlEscolaridade'), true);
                    }
                },
                error: function (response) {
                    //$("#modalErro").modal("show");
                    exibeError($('#ddlEscolaridade'), true);
                    window.location.href = "../../Erro.aspx";
                }
            });

        }

        // método responsável por validar os campos do form
        function validaFormulario() {

            //$(".has-error").removeClass("has-error");

            if ($("#lblOperacao").text().indexOf("Inclusão") > -1) {
                if ($('#ddlNumeroCartaoTitular')[0].selectedIndex < 1) {
                    exibeCampoObrigatorio($('#ddlNumeroCartaoTitular'));
                    $('#ddlNumeroCartaoTitular').focus();
                    return false;
                }
            }

            if ($('#txtNome').val().trim() == "") {
                exibeCampoObrigatorio($('#txtNome'));
                $('#txtNome').focus();
                return false;
            }

            if ($('#txtNomeCartao').val().trim() == "") {
                exibeCampoObrigatorio($('#txtNomeCartao'));
                $('#txtNomeCartao').focus();
                return false;
            }

            if ($('#txtCpf').val().trim() == "") {
                exibeCampoObrigatorio($('#txtCpf'));
                $('#txtCpf').focus();
                return false;
            }

            if (!validaCpf($('#txtCpf').val().trim())) {
                exibeCampoObrigatorio($('#txtCpf'), "CPF inválido");
                $('#txtCpf').focus();
                return false;
            }

            if ($('input#hdnCpfTitular').val() == $('#txtCpf').val().replace('.', '').replace('.', '').replace('-', '')) {
                exibeCampoObrigatorio($('#txtCpf'), "O CPF do titular não pode ser um adicional");
                return false;
            }

            if (!validaAdicional($('#txtCpf').val().trim(), false)) {
                exibeCampoObrigatorio($('#txtCpf'), "Adicional já cadastrado");
                return false;
            }

            if ($('#txtDataNascimento').val().trim() == "") {
                exibeCampoObrigatorio($('#txtDataNascimento'));
                $('#txtDataNascimento').focus();
                return false;
            }

            if (!comparaDataAtual($('#txtDataNascimento').val().trim())) {
                exibeCampoObrigatorio($('#txtDataNascimento'), "Data inválida");
                $('#txtDataNascimento').focus();
                return false;
            }

            if (!validaData($('#txtDataNascimento').val().trim())) {
                exibeCampoObrigatorio($('#txtDataNascimento'), "Data inválida");
                $('#txtDataNascimento').focus();
                return false;
            }

            if ($('#ddlSexo')[0].selectedIndex < 1) {
                exibeCampoObrigatorio($('#ddlSexo'));
                $('#ddlSexo').focus();
                return false;
            }

            if (USUARIO == "PF") {
                if ($('#ddlParentesco')[0].selectedIndex < 1) {
                    exibeCampoObrigatorio($('#ddlParentesco'));
                    $('#ddlParentesco').focus();
                    return false;
                }

                if ($('#ddlEscolaridade')[0].selectedIndex < 1) {
                    exibeCampoObrigatorio($('#ddlEscolaridade'));
                    $('#ddlEscolaridade').focus();
                    return false;
                }
            }

            var valorLimitesProduto = 0.0;
            var limites = $('[id*=valorLimite]');
            for (var i = 0; i < limites.length; i++) {
                var item = $(limites[i]);
                if (item.val().trim() == "") {
                    exibeCampoObrigatorio(item);
                    item.focus();
                    return false;
                }
            }

            var listaLimite = [];
            var limite;
            for (var i = 0; i < limites.length; i++) {
                var item = $(limites[i]);
                limite = { 'CodLimite': item.attr('data-cod_limite'), 'CodTipoLimite': item.attr('data-cod_tipo_limite'), 'CodConta': item.attr('data-cod_conta'), 'CodProduto': item.attr('data-cod_produto'), 'ValorLimite': item.val() };
                listaLimite.push(limite);
            }
            $('input#hdnListaLimites').val(JSON.stringify(listaLimite));


            if ($('#ddlBloqueadoExterior')[0].selectedIndex < 1) {
                exibeCampoObrigatorio($('#ddlBloqueadoExterior'));
                $('#ddlBloqueadoExterior').focus();
                return false;
            }

            if ($('#ddlBloqueadoExterior option:selected').text() == "Não") {
                if ($('#txtFaixaIniBloqExt').val().trim() == "") {
                    exibeCampoObrigatorio($('#txtFaixaIniBloqExt'));
                    $('#txtFaixaIniBloqExt').focus();
                    return false;
                }
                if (!validaData($('#txtFaixaIniBloqExt').val().trim())) {
                    exibeCampoObrigatorio($('#txtFaixaIniBloqExt'), "Data inválida");
                    $('#txtFaixaIniBloqExt').focus();
                    return false;
                }

                if ($('#txtFaixaFimBloqExt').val().trim() == "") {
                    exibeCampoObrigatorio($('#txtFaixaFimBloqExt'));
                    $('#txtFaixaFimBloqExt').focus();
                    return false;
                }

                if (!validaData($('#txtFaixaFimBloqExt').val().trim())) {
                    exibeCampoObrigatorio($('#txtFaixaFimBloqExt'), "Data inválida");
                    $('#txtFaixaFimBloqExt').focus();
                    return false;
                }

                if (!comparaData($('#txtFaixaIniBloqExt').val().trim(), $('#txtFaixaFimBloqExt').val().trim())) {
                    exibeCampoObrigatorio($('#txtFaixaIniBloqExt'), "A data incial não pode ser maior que a data final");
                    $('#txtFaixaIniBloqExt').focus();
                    return false;
                }

            }

            //if ($('#ddlStatusCartao')[0].selectedIndex < 1) {
            //    exibeCampoObrigatorio($('#ddlStatusCartao'));
            //    $('#ddlStatusCartao').focus();
            //    return false;
            //}

            //if ($('#ddlStatusCartao option:selected').text() == "Bloqueado") {
            //    if ($('#ddlTipoBloqueio')[0].selectedIndex < 1) {
            //        exibeCampoObrigatorio($('#ddlTipoBloqueio'));
            //        $('#ddlTipoBloqueio').focus();
            //        return false;
            //    }

            //}

            $(".loading").fadeIn("slow");

            return true;

        }

    </script>
</head>
<body class="fadeIn">
    <form id="form1" autocomplete="off" runat="server">
    <asp:ScriptManager runat="server">
    </asp:ScriptManager>
    <div class="container">
        <div class="content">
            <div class="row">
                <div class="col-md-12">
                    <h3 class="page-header">Adicional</h3>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel-body">
                        <div class="row">
                            <div class="panel panel-default">
                                <div class="panel-heading panel-font">
                                    <b>
                                        <asp:Label ID="lblOperacao" runat="server" CssClass="panel-font" Text="Adicional"></asp:Label></b>
                                    <asp:HiddenField ID="hdnOperacao" runat="server" Value="" />
                                    <asp:HiddenField ID="hdnUsuario" runat="server" Value="" />
                                </div>
                                <div class="panel-body">
                                    <div class="row row-margin">
                                        <div class="panel panel-default">
                                            <div class="panel-heading panel-font">
                                                Dados do Titular
                                            </div>
                                            <div class="panel-body">
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <asp:Label ID="Label1" runat="server" Text="Número do Cartão do Titular:" CssClass="control-label"></asp:Label>
                                                        <asp:TextBox ID="txtNumeroCartaoTitular" runat="server" CausesValidation="True" CssClass="form-control"
                                                            disabled></asp:TextBox>
                                                        <asp:DropDownList ID="ddlNumeroCartaoTitular" runat="server" CausesValidation="True"
                                                            data-required="true" CssClass="form-control">
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <asp:Label ID="lblNome" runat="server" Text="Nome do Cliente Titular:" CssClass="control-label"></asp:Label>
                                                    <asp:TextBox ID="txtNomeTitular" runat="server" CausesValidation="True" CssClass="form-control input-capitalize"
                                                        disabled></asp:TextBox>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row row-margin">
                                        <div class="panel panel-default">
                                            <div class="panel-heading panel-font">
                                                Dados do Adicional
                                            </div>
                                            <asp:HiddenField ID="hdnCodAdicional" runat="server" Value="" />
                                            <asp:HiddenField ID="hdnCodConta" runat="server" Value="" />
                                            <asp:HiddenField ID="hdnCodCartaoAdicional" runat="server" Value="" />
                                            <asp:HiddenField ID="hdnCodCartaoTitular" runat="server" Value="" />
                                            <asp:HiddenField ID="hdnCodProdutoCartao" runat="server" Value="" />
                                            <asp:HiddenField ID="hdnLimiteProduto" runat="server" Value="" />
                                            <asp:HiddenField ID="hdnCnpjTitular" runat="server" Value="" />
                                            <asp:HiddenField ID="hdnCpfTitular" runat="server" Value="" />
                                            <asp:HiddenField ID="hdnCpfAdicional" runat="server" Value="" />
                                            <div class="panel-body">
                                                <div class="row">
                                                    <div class="col-md-4 display-none" id="divNumeroCartaoAdicional">
                                                        <div class="form-group">
                                                            <asp:Label ID="Label9" runat="server" Text="Número do Cartão do Adicional:" CssClass="control-label"></asp:Label>
                                                            <asp:TextBox ID="txtNumeroCartaoAdicional" runat="server" CssClass="form-control"
                                                                disabled></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <asp:Label ID="Label2" runat="server" Text="Nome Completo do Adicional:" CssClass="control-label"></asp:Label>
                                                            <asp:TextBox ID="txtNome" runat="server" MaxLength="300" placeholder="Nome completo do adicional"
                                                                data-required="true" CssClass="form-control input-capitalize"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <asp:Label ID="Label8" runat="server" Text="Nome do Adicional no Cartão:" CssClass="control-label"></asp:Label>
                                                            <asp:TextBox ID="txtNomeCartao" runat="server" placeholder="Nome do adicional no cartão"
                                                                data-required="true" MaxLength="25" CssClass="form-control input-uppercase"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="row" style="margin-top: 5px">
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <asp:Label ID="Label4" runat="server" Text="CPF do Adicional:" CssClass="control-label"></asp:Label>
                                                            <asp:TextBox ID="txtCpf" runat="server" placeholder="CPF do adicional" data-required="true"
                                                                CssClass="form-control input-cpf"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <asp:Label ID="Label5" runat="server" Text="Data de Nascimento:" CssClass="control-label"></asp:Label>
                                                            <%--<label class="control-label">Data de Nascimento:</label>--%>
                                                            <asp:TextBox ID="txtDataNascimento" runat="server" placeholder="Data de nascimento"
                                                                data-required="true" CssClass="form-control input-date" Width="200px"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <asp:Label ID="Label6" runat="server" Text="Sexo:" CssClass="control-label"></asp:Label>
                                                            <asp:DropDownList ID="ddlSexo" runat="server" data-required="true" CssClass="form-control"
                                                                Width="200px">
                                                                <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                                                <asp:ListItem Text="Feminino" Value="1" />
                                                                <asp:ListItem Text="Masculino" Value="2" />
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div id="divSomentePessoaFisica" class="row" style="margin-top: 5px">
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <asp:Label ID="Label7" runat="server" Text="Parentesco:" CssClass="control-label"></asp:Label>
                                                            <asp:DropDownList ID="ddlParentesco" runat="server" data-required="true" CausesValidation="True"
                                                                CssClass="form-control" Width="200px">
                                                                <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <asp:Label ID="Label13" runat="server" Text="Escolaridade:" CssClass="control-label"></asp:Label>
                                                            <asp:DropDownList ID="ddlEscolaridade" runat="server" data-required="true" CausesValidation="True"
                                                                CssClass="form-control" Width="200px">
                                                                <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="row display-none" id="divLimitesProduto">
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <asp:Label ID="Label17" runat="server" Text="Limite Total do Produto:" CssClass="control-label"></asp:Label>
                                                            <div class="input-group">
                                                                <span class="input-group-addon">R$</span>
                                                                <asp:TextBox ID="txtLimiteProduto" runat="server" MaxLength="15" placeholder="Limite total do produto"
                                                                    data-required="true" CssClass="form-control input-money" disabled></asp:TextBox>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-6 bs-glyphicons">
                                                        <asp:Label ID="Label16" runat="server" Text="Limites do Produto:" CssClass="control-label"></asp:Label>
                                                        <%--<div class="display-none" id="divLimitesProduto">--%>
                                                        <asp:HiddenField ID="hdnListaLimites" runat="server" Value="" />
                                                        <table id="table-limites" class="table table-hover">
                                                            <tbody>
                                                            </tbody>
                                                        </table>
                                                        <%--</div>--%>
                                                    </div>
                                                </div>
                                                <div class="row" style="margin-top: 5px">
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <asp:Label ID="Label14" runat="server" Text="Bloqueado Exterior:" CssClass="control-label"></asp:Label>
                                                            <asp:DropDownList ID="ddlBloqueadoExterior" runat="server" data-required="true" CausesValidation="True"
                                                                CssClass="form-control" Width="200px">
                                                                <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                                                <asp:ListItem Text="Sim" Value="1" />
                                                                <asp:ListItem Text="Não" Value="0" />
                                                            </asp:DropDownList>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4 display-none" id="divFaixaIniBloqExt" runat="server">
                                                        <div class="form-group">
                                                            <asp:Label ID="Label15" runat="server" Text="Data Início da Vigência:" CssClass="control-label"></asp:Label>
                                                            <asp:TextBox ID="txtFaixaIniBloqExt" runat="server" MaxLength="10" data-required="true"
                                                                placeholder="Data início" CssClass="form-control input-date" Width="200px"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4" id="divFaixaFimBloqExt" runat="server" style="display: none">
                                                        <div class="form-group">
                                                            <asp:Label ID="Label12" runat="server" Text="Data Fim da Vigência:" CssClass="control-label"></asp:Label>
                                                            <asp:TextBox ID="txtFaixaFimBloqExt" runat="server" MaxLength="10" data-required="true"
                                                                placeholder="Data fim" CssClass="form-control input-date" Width="200px"></asp:TextBox>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="row" style="margin-top: 5px">
                                                    <div class="col-md-4">
                                                        <div class="form-group">
                                                            <asp:Label ID="Label10" runat="server" Text="Status do Cartão:" CssClass="control-label"></asp:Label>
                                                            <%--<asp:DropDownList ID="ddlStatusCartao" runat="server" CausesValidation="True" data-required="true"
                                                                CssClass="form-control" Width="200px">
                                                            </asp:DropDownList>--%>
                                                            <asp:Label ID="lblStatusCartao" runat="server" CssClass="control-label-box-default" Width="200px"></asp:Label>
                                                        </div>
                                                    </div>
                                                    <div class="col-md-4" id="divTipoBloqueio" runat="server">
                                                        <div class="form-group">
                                                            <asp:Label ID="Label11" runat="server" Text="Tipo do Bloqueio:" CssClass="control-label"></asp:Label>
                                                            <%--<asp:DropDownList ID="ddlTipoBloqueio" runat="server" CausesValidation="True" data-required="true"
                                                                CssClass="form-control" Width="200px">
                                                            </asp:DropDownList>--%>
                                                            <asp:Label ID="lblMotivo" runat="server" CssClass="control-label-box-default" Width="200px"></asp:Label>
                                                        </div>
                                                    </div>
                                                    <br />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <center>
                                            <div class="col-md-12">
                                                <asp:LinkButton ID="btnConfirmar" CssClass="btn btn-primary" runat="server" OnClientClick="javascript:return validaFormulario();"
                                                    OnClick="btnConfirmar_Click">Confirmar <i class="fa fa-check"></i></asp:LinkButton>
                                            </div>
                                        </center>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-12">
                                            <%--<asp:Button ID="btnVoltar" runat="server" CssClass="btn btn-link" Text="Voltar" OnClick="btnVoltar_Click" />--%>
                                            <a type="button" href="MenuAdicional.aspx" id="btnVoltar" runat="server" class="btn btn-link">
                                                Voltar</a>
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
    <div class="modal fade alert" id="modalErro" tabindex="-1" role="dialog" aria-labelledby="myModalLabel"
        aria-hidden="true">
        <div class="modal-dialog alert-danger" style="width: 450px">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        Cartão Adicional</h4>
                </div>
                <div class="modal-body align-center" style="font-size: 18px !important;">
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
    </form>
</body>
<script language="JavaScript" type="text/javascript">
    $(".loading").fadeIn("slow");

    var OPERACAO = $('input#hdnOperacao').val();
    var USUARIO = $('input#hdnUsuario').val();

    if (USUARIO == "PJ") {
        $("#divSomentePessoaFisica").hide();
    }

    if (OPERACAO.toUpperCase() == "INCLUIR") {
        $("#divNumeroCartaoAdicional").fadeOut("slow");

        //carregaStatusCartao();
        //carregaTipoBloqueioCartao();

        carregaListaTipoGrauParentesco();
        carregaListaEscolaridade();

    }
    else {
        $("#divNumeroCartaoAdicional").fadeIn("slow");

    }

    //$('#divLimitesProduto').fadeOut("slow");
    //if ($("#lblOperacao").text().indexOf("Inclusão") == -1) {
    //    var codProduto = $('input#hdnCodProdutoCartao').val();
    //    var codConta = $('input#hdnCodConta').val();
    //    var codAdicional = $('input#hdnCodAdicional').val();
    //    carregaListaLimiteProduto(codConta, codProduto, codAdicional);
    //}

    if ($('#ddlBloqueadoExterior option:selected').text() == "Não") {
        $('#divFaixaIniBloqExt').fadeIn("slow");
        $('#divFaixaFimBloqExt').fadeIn("slow");
    }
    else {
        $('#divFaixaIniBloqExt').fadeOut("slow");
        $('#divFaixaFimBloqExt').fadeOut("slow");
    }

    //$('#ddlStatusCartao').attr("disabled", "disabled");
    //$('#ddlTipoBloqueio').attr("disabled", "disabled");

    //if ($('#ddlStatusCartao option:selected').text() == "Bloqueado") {
    //    $('#divTipoBloqueio').fadeIn("slow");
    //}
    //else {
    //    $('#divTipoBloqueio').fadeOut(500)
    //}

    $(".loading").fadeOut("slow");

</script>
</html>

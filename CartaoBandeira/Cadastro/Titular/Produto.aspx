<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeFile="Produto.aspx.cs"
    Inherits="Produto" %>
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

    <link rel="stylesheet" type="text/css" href="../../css/cssProduto.css" />

    <script language="javascript" type="text/javascript" src="../../js/jquery-3.1.1.min.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/jquery.mask.min.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/jquery.maskMoney.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/bootstrap.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/metisMenu/metisMenu.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/sb-admin-2.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/default.js"></script>
    <script language="javascript" type="text/javascript">
        var Usuario = "";
        var ArrayVencimentoFatura = {};
        var ArrayRendaProduto = {};
        var ArrayRendaGrupoTarifaDefault = {};
        var ArrayBandeiraVencimento = {};
        var DivConta = false;
        var DivLimite = false;

        $(document).ready(function () {

            carregaListaBandeira();
            carregaListaVencimento();
            carregaVencimentoEmissor();
            carregaTipoOperacaoCartao();
            carregaListaBanco();

            carregaStatusCartao();
            carregaTipoBloqueioCartao();

            $('#ddlBandeira').change(function () {
                carregaListaProduto();
            });

            $("#txtNomeCartao").focusout(function (event) {
                $(this).val(removerAcentos($(this).val()));
            });

            $('#txtLimiteProduto').focusout(function (e) {

                if ($('#txtLimiteConta').val().trim() != "" & $('#txtLimiteProduto').val().trim() != "") {
                    var valorConta = retornaFloat($('#txtLimiteConta').val());
                    var valorProduto = retornaFloat($('#txtLimiteProduto').val());

                    if (valorProduto > valorConta) {
                        setTimeout(function () { exibeError($('#txtLimiteProduto'), true); exibePopover($('#txtLimiteProduto'), "O limite do produto não pode ser maior que o limite disponível da conta"); }, 100);

                    }
                }

            });

            $("#ddlTipoOperacaoCartao").change(function () {
                var tipo = $('#ddlTipoOperacaoCartao option:selected').text();
                var deb = $('#ddlDebAutomatico option:selected').text();

                if ($('#txtLimiteConta').val().trim() == "" || $('#txtLimiteConta').val() == "0,00") {
                    if (tipo != "Débito") {
                        $("#btnLimiteIndisponivel").attr("href", "Limite.aspx?conta=" + conta);
                        habilitaCadastroProduto(false);
                        return;
                    }
                    else {
                        habilitaCadastroProduto(true);
                    }
                }

                if (tipo != "Crédito" && tipo != "Selecione") {
                    $('#divConta').slideDown();
                    DivConta = true;
                }
                else {

                    if (deb != "Sim") {
                        $('#divConta').slideUp();
                        DivConta = false;
                    }
                    else if (deb == "Selecione" & tipo == "Selecione") {
                        $('#divConta').slideUp();
                        DivConta = false;
                    }
                }

                exibeError($('#txtLimiteProduto'), false);
                if (tipo == "Débito") {
                    $('#divLimiteProduto').fadeOut("slow");
                    $('#ddlDebAutomatico').val('1');
                    $("#ddlDebAutomatico").attr("disabled", "disabled");
                }
                else {
                    $('#divLimiteProduto').fadeIn("slow");
                    $('#ddlDebAutomatico').val('');
                    $("#ddlDebAutomatico").removeAttr("disabled");
                }

                $("#ddlProduto").trigger("change");

            });

            $("#ddlDebAutomatico").change(function () {
                var deb = $('#ddlDebAutomatico option:selected').text();

                if (deb == "Sim") {
                    $('#divConta').slideDown();
                    DivConta = true;
                }
                else {
                    var tipo = $('#ddlTipoOperacaoCartao option:selected').text();

                    if (tipo == "Crédito" || tipo == "Selecione") {
                        $('#divConta').slideUp();
                        DivConta = false;
                    }
                }

            });

            $('#ddlProduto').change(function () {

                if (isNullOrEmpty($('#ddlProduto').val())) {
                    $('#divLimitesProduto').slideUp();
                    DivLimite = false;

                    $('#ddlGrupoTarifa').empty();
                    $('#ddlGrupoTarifa').popover('destroy');
                    $('#txtVencimentoGrupoTarifario').val('');

                    return false;
                }

                var listaProduto = $.parseJSON($('input#hdnListaProdutos').val());
                var existeProduto = false;
                $.each(listaProduto, function (index, item) {
                    if (item == $('#ddlProduto').val()) {
                        existeProduto = true;
                        return;
                    }
                })

                if (existeProduto) {

                    exibeCampoObrigatorio($('#ddlProduto'), "O Produto <b>" + $("#ddlProduto option:selected").text() + "</b> já existe");

                    $('#divLimitesProduto').slideUp();
                    DivLimite = false;

                    $('#ddlGrupoTarifa').empty();
                    $('#ddlGrupoTarifa').popover('destroy');
                    $('#txtVencimentoGrupoTarifario').val('');

                    $('#divVencimentoGrupoTarifario').fadeOut("slow");
                    $('#txtVencimentoGrupoTarifario').val('');

                    $('#ddlProduto').focus();
                    return false;
                }

                var rendaProduto = ArrayRendaProduto[$(this).val()];
                var renda = retornaFloat($('#txtRendaMensal').val());

                if (renda < rendaProduto) {
                    exibeCampoObrigatorio($('#ddlProduto'), "A renda é insuficiente para o Produto <b>" + $("#ddlProduto option:selected").text() + "</b>");

                    $('#divLimitesProduto').slideUp();

                    $('#ddlGrupoTarifa').empty();
                    $('#ddlGrupoTarifa').popover('destroy');
                    $('#txtVencimentoGrupoTarifario').val('');

                    $('#divVencimentoGrupoTarifario').fadeOut("slow");
                    $('#txtVencimentoGrupoTarifario').val('');

                    $('#ddlProduto').focus();
                    return false;
                }

                var tipoOperacao = $('#ddlTipoOperacaoCartao option:selected').text();
                if (tipoOperacao == "Débito") {
                    $('#divLimitesProduto').slideUp();
                    DivLimite = false;

                    $('#ddlGrupoTarifa').empty();
                    $('#ddlGrupoTarifa').popover('destroy');
                    $('#txtVencimentoGrupoTarifario').val('');

                    return false;
                }

                if (tipoOperacao == "Crédito" || tipoOperacao == "Múltiplo") {
                    exibeError($('#ddlProduto'), false);

                    var codConta = 0;
                    var codProduto = $('#ddlProduto option:selected').val();
                    var codAdicional = 0;

                    carregaListaLimiteProduto(codConta, codProduto, codAdicional);

                    carregaListaGrupoTarifa(codProduto);
                }

            });

            $('#ddlGrupoTarifa').change(function () {
                carregaGrupoTarifa();
            });

            $("#txtFaixaIniBloqExt, #txtFaixaFimBloqExt").keyup(function () {
                exibeError($('#txtFaixaIniBloqExt'), false);
                exibeError($('#txtFaixaFimBloqExt'), false);
            });

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


            $("#ddlStatusCartao").change(function () {

                var valor = $('#ddlStatusCartao option:selected').text();
                $("#ddlTipoBloqueio ").val('')

                if (valor == "Bloqueado") {
                    $('#divTipoBloqueio').fadeIn(500)
                    $("#ddlTipoBloqueio ").focus();
                }
                else {
                    $('#divTipoBloqueio').fadeOut(500)
                }

                exibeError($('#ddlStatusCartao'), false);

            });


            $("#ddlDiaVencimento").change(function () {
                var faturamento = ArrayVencimentoFatura[$(this).val()];
                if ($('#ddlDiaVencimento').val() != '') {
                    $("#txtDiaFaturamento").val(faturamento);
                }
            });

        });

        function validaFormulario() {
            var valida = false;

            try {

                valida = validaDadosCartao();

            }
            catch (err) {
                $("#MensagemErro").text('Erro ao validar os dados do cliente!');
                $("#modalErro").modal("show");
                return false;
            }

            return valida

        }

        function validaDadosCartao() {
            var valida = true;

            if ($('#ddlTipoOperacaoCartao option:selected').text() != "Débito") {
                if ($('#txtLimiteProduto').val().trim() == "" || $('#txtLimiteProduto').val() == "0,00") {
                    exibeCampoObrigatorio($('#txtLimiteProduto'));
                    $('#txtLimiteProduto').focus();
                    return false;
                }
            }
            else {
                $('#txtLimiteProduto').val('');
            }

            var valorConta = retornaFloat($('#txtLimiteConta').val());
            var valorProduto = retornaFloat($('#txtLimiteProduto').val());

            if (valorProduto > valorConta) {
                exibeCampoObrigatorio($('#txtLimiteProduto'), "O limite do Produto não pode ser maior que o limite disponível da conta");
                $('#txtLimiteProduto').focus();
                return false;
            }

            if ($('#ddlTipoOperacaoCartao')[0].selectedIndex < 1) {
                exibeCampoObrigatorio($('#ddlTipoOperacaoCartao'));
                $('#ddlTipoOperacaoCartao').focus();
                return false;
            }

            if ($('#ddlBandeira')[0].selectedIndex < 1) {
                exibeCampoObrigatorio($('#ddlBandeira'));
                $('#ddlBandeira').focus();
                return false;
            }

            if ($('#ddlProduto option').length == 0) {
                exibeCampoObrigatorio($('#ddlBandeira'), "A Bandeira <b>" + $("#ddlBandeira option:selected").text() + "</b> não possui Produto cadastrado");
                $('#ddlBandeira').focus();
                return false;
            }

            if ($('#ddlProduto')[0].selectedIndex < 1) {
                exibeCampoObrigatorio($('#ddlProduto'));
                $('#ddlProduto').focus();
                return false;
            }

            var listaProduto = $.parseJSON($('input#hdnListaProdutos').val());
            var existeProduto = false;
            $.each(listaProduto, function (index, item) {
                if (item == $('#ddlProduto').val()) {
                    existeProduto = true;
                    return;
                }
            })

            if (existeProduto) {
                exibeCampoObrigatorio($('#ddlProduto'), "O Produto <b>" + $("#ddlProduto option:selected").text() + "</b> já existe");
                $('#ddlProduto').focus();
                return false;
            }

            var rendaProduto = ArrayRendaProduto[$('#ddlProduto').val()];
            var renda = retornaFloat($('#txtRendaMensal').val());

            if (renda < rendaProduto) {

                if (Usuario == "PJ")
                    exibeCampoObrigatorio($('#ddlProduto'), "O patrimônio liquido é insuficiente para o Produto selecionado");
                else
                    exibeCampoObrigatorio($('#ddlProduto'), "A renda mensal é insuficiente para o Produto selecionado");

                $('#ddlProduto').focus();
                return false;
            }

            $('input#hdnListaLimites').val('');
            var tipoOperacao = $('#ddlTipoOperacaoCartao option:selected').text();
            if (DivLimite && tipoOperacao != "Débito") {
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
                    limite = { 'CodLimite': item.attr('data-cod_limite'), 'CodTipoLimite': item.attr('data-cod_tipo_limite'), 'ValorLimite': item.val() };
                    listaLimite.push(limite);
                }
                $('input#hdnListaLimites').val(JSON.stringify(listaLimite));

                if ($('#ddlGrupoTarifa')[0].selectedIndex < 1) {
                    if ($('#ddlGrupoTarifa option').length == 0)
                        exibeCampoObrigatorio($('#ddlGrupoTarifa'), "O Produto <b>" + $("#ddlProduto option:selected").text() + "</b> não possui <b>Grupo Tarifário</b> cadastrado");
                    else
                        exibeCampoObrigatorio($('#ddlGrupoTarifa'));

                    $('#ddlGrupoTarifa').focus();
                    return false;
                }

                if (!ArrayRendaGrupoTarifaDefault[$('#ddlGrupoTarifa').val()]) {
                    if ($('#txtVencimentoGrupoTarifario').val().trim() == "") {
                        exibeCampoObrigatorio($('#txtVencimentoGrupoTarifario'));
                        $('#txtVencimentoGrupoTarifario').focus();
                        return false;
                    }
                    if (!validaData($('#txtVencimentoGrupoTarifario').val().trim())) {
                        exibeCampoObrigatorio($('#txtVencimentoGrupoTarifario'), "Data inválida");
                        $('#txtVencimentoGrupoTarifario').focus();
                        return false;
                    }
                }
                else {
                    $('#txtVencimentoGrupoTarifario').val('');
                }
            }
            else if (tipoOperacao == "Crédito" || tipoOperacao == "Múltiplo") {
                exibeCampoObrigatorio($('#ddlProduto'), "O Produto <b>" + $("#ddlProduto option:selected").text() + "</b> não possui Limites cadastrado");
                $('#ddlProduto').focus();
                return false;
            }

            if (!validaDadosBancarios()) {
                return false;
            }

            if ($('#ddlDiaVencimento')[0].selectedIndex < 1) {
                exibeCampoObrigatorio($('#ddlDiaVencimento'));
                $('#ddlDiaVencimento').focus();
                return false;
            }

            if ($('#txtNomeCartao').val().trim() == "") {
                exibeCampoObrigatorio($('#txtNomeCartao'));
                $('#txtNomeCartao').focus();
                return false;
            }

            $('input#hdnDataVencimentoBandeira').val($('#txtDataVencimentoBandeira').val());
            $('input#hdnDataVencimentoEmissor').val($('#txtDataVencimentoEmissor').val());

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

                if (!validaData($('#txtFaixaFimBloqExt').val().trim())) {
                    exibeCampoObrigatorio($('#txtFaixaFimBloqExt'), "Data inválida");
                    $('#txtFaixaFimBloqExt').focus();
                    return false;
                }

                if (!comparaData($('#txtFaixaIniBloqExt').val().trim(), $('#txtFaixaFimBloqExt').val().trim())) {
                    exibeCampoObrigatorio($('#txtFaixaIniBloqExt'), "A data inicial não pode ser maior que a data final");
                    $('#txtFaixaIniBloqExt').focus();
                    return false;
                }

            }
            else {
                $('#txtFaixaIniBloqExt').val('');
                $('#txtFaixaIniBloqExt').val('');
            }

            if ($('#ddlStatusCartao')[0].selectedIndex < 1) {
                exibeCampoObrigatorio($('#ddlStatusCartao'));
                $('#ddlStatusCartao').focus();
                return false;
            }

            if ($('#ddlStatusCartao option:selected').text() == "Bloqueado") {
                if ($('#ddlTipoBloqueio')[0].selectedIndex < 1) {
                    exibeCampoObrigatorio($('#ddlTipoBloqueio'));
                    $('#ddlTipoBloqueio').focus();
                    return false;
                }

            }

            return valida;
        }

        function validaDadosBancarios() {
            var valida = true;

            if ($('#ddlDebAutomatico')[0].selectedIndex < 1) {
                exibeCampoObrigatorio($('#ddlDebAutomatico'));
                $('#ddlDebAutomatico').focus();
                return false;
            }

            if (DivConta) {
                if ($('#ddlBanco')[0].selectedIndex < 1) {
                    exibeCampoObrigatorio($('#ddlBanco'));
                    $('#ddlBanco').focus();
                    return false;
                }

                if ($('#txtAgencia').val().trim() == "") {
                    exibeCampoObrigatorio($('#txtAgencia'));
                    $('#txtAgencia').focus();
                    return false;
                }

                if ($('#txtContaCorrente').val().trim() == "") {
                    exibeCampoObrigatorio($('#txtContaCorrente'));
                    $('#txtContaCorrente').focus();
                    return false;
                }
            }
            else {
                $('#ddlBanco').val('');
                $('#txtAgencia').val('');
                $('#txtAgenciaDv').val('');
                $('#txtContaCorrente').val('');
                $('#txtContaCorrenteDv').val('');
            }

            return valida;

        }


        function verificaLimiteConta() {

            if ($('#txtLimiteConta').val().trim() == "" || $('#txtLimiteConta').val() == "0,00") {

                $("#btnLimiteIndisponivel").attr("href", "Limite.aspx?conta=" + conta);

                $("#ddlTipoOperacaoCartao").val("2");

                $('#divLimiteProduto').fadeOut("slow");
                $('#ddlDebAutomatico').val('1');
                $("#ddlDebAutomatico").attr("disabled", "disabled");

            }

        }

        function habilitaCadastroProduto(valor) {

            if (valor) {
                $("#divLimiteIndisponivel").slideUp();

                $("#txtLimiteProduto").removeAttr("disabled");
                $("#ddlBandeira").removeAttr("disabled");
                $("#ddlProduto").removeAttr("disabled");
                //$("#ddlTipoOperacaoCartao").removeAttr("disabled");
                $("#ddlDiaVencimento").removeAttr("disabled");
                $("#txtNomeCartao").removeAttr("disabled");
                $("#ddlBloqueadoExterior").removeAttr("disabled");
                $("#ddlDebAutomatico").removeAttr("disabled");
                $("#btnConfirmar").removeAttr("disabled");

            }
            else {
                $("#divLimiteIndisponivel").slideDown();

                $("#txtLimiteProduto").attr("disabled", "disabled");
                $("#ddlBandeira").attr("disabled", "disabled");
                $("#ddlProduto").attr("disabled", "disabled");
                //$("#ddlTipoOperacaoCartao").attr("disabled", "disabled");
                $("#ddlDiaVencimento").attr("disabled", "disabled");
                $("#txtNomeCartao").attr("disabled", "disabled");
                $("#ddlBloqueadoExterior").attr("disabled", "disabled");
                $("#ddlDebAutomatico").attr("disabled", "disabled");
                $("#btnConfirmar").attr("disabled", "disabled");

                $('#divConta').slideUp();
                DivConta = false;

            }

        }

        function carregaListaBandeira() {

            ArrayBandeiraVencimento = {};

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Produto.aspx/ObterListaBandeira',
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        //$('#ddlBandeira').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));
                        $.each(jsonResult.Resultado, function (index, item) {
                            $('#ddlBandeira').append($('<option>', { text: item.Nome, value: item.CodBandeira }, '</option>'));

                            ArrayBandeiraVencimento[item.CodBandeira] = item.DiasRenovacaoCartao

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
                        exibeError($('#ddlBandeira'), true);
                    }

                },
                error: function (response) {
                    //$("#modalErro").modal("show");
                    exibeError($('#ddlBandeira'), true);
                    window.location.href = "../../Erro.aspx";
                }
            });
        }

        function carregaListaVencimento() {

            ArrayVencimentoFatura = {};

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Produto.aspx/ObterDadosVencimentoFatura',
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        //$('#ddlDiaVencimento').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));
                        $.each(jsonResult.Resultado, function (index, item) {
                            $('#ddlDiaVencimento').append($('<option>', { value: item.CodVencimento, text: item.DiaVencimento }, '</option>'));

                            ArrayVencimentoFatura[item.CodVencimento] = item.DiaFaturamento

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
                        exibeError($('#ddlDiaVencimento'), true);
                    }

                },
                error: function (response) {
                    //$("#modalErro").modal("show");
                    exibeError($('#ddlDiaVencimento'), true);
                    window.location.href = "../../Erro.aspx";
                }
            });
        }

        function carregaListaProduto() {

            ArrayRendaProduto = {};

            $('#ddlProduto').empty();
            $("#ddlProduto").attr("disabled", "disabled");
            exibeError($('#ddlProduto'), false);

            $('#ddlGrupoTarifa').empty();
            $('#ddlGrupoTarifa').popover('destroy');
            $("#txtVencimentoGrupoTarifario").val('');

            $('#divLimitesProduto').slideUp();
            $('#divDataVencimentoBandeira').fadeOut("slow")

            if ($('#ddlBandeira').val() == '') {
                return;
            }

            var dias = ArrayBandeiraVencimento[$('#ddlBandeira').val()];
            var vencimento = new Date();
            vencimento.setDate(vencimento.getDate() + dias);
            $('#txtDataVencimentoBandeira').val(toFormatString(vencimento));
            $('#divDataVencimentoBandeira').fadeIn("slow")

            var param = JSON.stringify({
                codBandeira: $('#ddlBandeira option:selected').val()
            });

            $(".loading").fadeIn("slow");

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Produto.aspx/ObterListaProduto',
                data: param,
                dataType: "json",
                async: false,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        $('#ddlProduto').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));

                        $.each(jsonResult.Resultado, function (index, item) {
                            $('#ddlProduto').append($('<option>', { text: item.Nome, value: item.CodProduto }, '</option>'))

                            ArrayRendaProduto[item.CodProduto] = item.RendaMinima

                        })

                        $("#ddlProduto").removeAttr("disabled");
                        $('#divLimitesProduto').slideUp();

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
                        exibeCampoObrigatorio($('#ddlBandeira'), "A Bandeira <b>" + $("#ddlBandeira option:selected").text() + "</b> não possui Produto cadastrado");
                    }

                    $(".loading").fadeOut("slow");

                },
                error: function (response) {
                    $(".loading").fadeOut("slow");

                    //$("#modalErro").modal("show");
                    exibeError($('#ddlProduto'), true);
                    window.location.href = "../../Erro.aspx";

                }
            });

        }

        function carregaListaGrupoTarifa(codProduto) {

            ArrayRendaGrupoTarifaDefault = {};

            $('#ddlGrupoTarifa').empty();
            $('#ddlGrupoTarifa').popover('destroy');
            exibeError($('#ddlGrupoTarifa'), false);

            $("#txtVencimentoGrupoTarifario").val('');

            var param = JSON.stringify({
                codProduto: codProduto
            });

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Produto.aspx/ObterListaGrupoTarifa',
                data: param,
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {
                        $('#ddlGrupoTarifa').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));

                        $.each(jsonResult.Resultado, function (index, item) {
                            $('#ddlGrupoTarifa').append($('<option>', { text: item.Nome, value: item.CodGrupoTarifa }, '</option>'));

                            ArrayRendaGrupoTarifaDefault[item.CodGrupoTarifa] = item.GrupoDefault
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
                        exibeCampoObrigatorio($('#ddlGrupoTarifa'), "O Produto <b>" + $("#ddlProduto option:selected").text() + "</b> não possui <b>Grupo Tarifário</b> cadastrado");
                    }

                },
                error: function (response) {
                    exibeError($('#ddlGrupoTarifa'), true);
                    window.location.href = "../../Erro.aspx";
                }
            });

        }

        function carregaListaLimiteProduto(codConta, codProduto, codAdicional) {
            $('#divLimitesProduto').slideUp();
            DivLimite = false;

            $('#ddlGrupoTarifa').empty();
            $('#ddlGrupoTarifa').popover('destroy');
            $('#txtVencimentoGrupoTarifario').val('');

            $('#divVencimentoGrupoTarifario').fadeOut("slow");
            $('#txtVencimentoGrupoTarifario').val('');

            $("#table-limites tbody tr").remove();

            if ($('#ddlProduto').val() == '')
                return;

            exibeError($('#txtLimiteProduto'), false);

            //$('#infoTotalLimite').text('')
            //$('#infoTotalDisponivel').text('')
            //codProduto: $('#ddlProduto option:selected').val()

            var param = JSON.stringify({
                codConta: codConta,
                codProduto: codProduto,
                codAdicional: codAdicional
            });

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Produto.aspx/ObterDadosLimiteProduto',
                data: param,
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        $.each(jsonResult.Resultado, function (index, item) {
                            DivLimite = true;

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

                            //if ($('#hdnTipoValorLimite').val() == '1') {
                            //    $('[id*=valorLimite]').maskMoney({ symbol: "R$", showSymbol: true, decimal: ",", thousands: ".", symbolStay: true, placeholder: "kkkk" });
                            //}

                            $('[id*=valorLimite]').unmask();
                            $('[id*=valorLimite]').mask('999', { placeholder: 'Valor' });

                        });

                        $('[id*=valorLimite]').focusout(function (event) {
                            if ($(this).val().trim() != "") {
                                $(this).val(parseInt($(this).val()));
                            }
                        });

                        $("[id*=valorLimite]").keypress(function (event) {
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
                            if (isKeyNumeric(event)) {
                                var value = this.value + event.key;
                                if (this.selectionStart == 0)
                                    value = event.key + this.value.toString();

                                if (value > 100)
                                    return false;
                            }
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

                        //if ($('#hdnTipoValorLimite').val() == '1') {
                        //    $('#infoTotalLimite').text('R$ 0,00')
                        //    $('#infoTotalDisponivel').text('R$ ' + $('#txtLimiteProduto').val())
                        //}
                        //else {
                        //    $('#infoTotalLimite').text('R$ 0%')
                        //    $('#infoTotalDisponivel').text('R$ ' + $('#txtLimiteProduto').val())
                        //}

                        calculaLimites();

                        $('#divLimitesProduto').slideDown();

                    }
                    else if (jsonResult.Resposta && jsonResult.Resultado.length == 0) {
                        exibeCampoObrigatorio($('#ddlProduto'), "O Produto <b>" + $("#ddlProduto option:selected").text() + "</b> não possui Limites cadastrado");
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
                        exibeError($('#ddlProduto'), true);
                    }
                },
                error: function (response) {
                    //$("#modalErro").modal("show");
                    exibeError($('#ddlProduto'), true);
                    window.location.href = "../../Erro.aspx";
                }

            });
        }

        function carregaGrupoTarifa() {

            if ($('#ddlGrupoTarifa').val() == '') {
                $('#ddlGrupoTarifa').popover('destroy');
                $('#divVencimentoGrupoTarifario').fadeOut("slow");
                $('#txtVencimentoGrupoTarifario').val('');
                return;
            }

            if (ArrayRendaGrupoTarifaDefault[$('#ddlGrupoTarifa').val()]) {
                $('#divVencimentoGrupoTarifario').fadeOut("slow");
            }
            else {
                $('#divVencimentoGrupoTarifario').fadeIn("slow");
                $('#txtVencimentoGrupoTarifario').focus();
            }

            var param = JSON.stringify({
                codGrupoTarifa: $('#ddlGrupoTarifa option:selected').val()
            });

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Produto.aspx/ObterDadosGrupoTarifa',
                data: param,
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {
                        var htmlGrupo = "<div style='width:433px; font-size: 13px' class='alert alert-info'>";
                        htmlGrupo += "<table class=''><thead><tr><th>Tarifa</th><th>Valor</th><th style='text-align: center'>Parcelas</th><th>Processo</th></tr></thead>";
                        htmlGrupo += "<tbody>";
                        $.each(jsonResult.Resultado, function (index, item) {
                            htmlGrupo += "<tr>"
                            htmlGrupo += "<td>" + item.NomeTarifa + "</td><td>" + item.ValorTarifa + "</td><td style='text-align: center'>" + item.QtdParcelas + "</td><td>" + item.Processo + "</td>";
                            htmlGrupo += "</tr>"
                        })

                        htmlGrupo += "</tbody></table></div>";

                        $('#ddlGrupoTarifa').popover('destroy');
                        $('#ddlGrupoTarifa').popover({ template: '<div><div class="popover-content"></div></div>', trigger: "hover", content: htmlGrupo, placement: "bottom", html: true });
                        setTimeout(function () { $("#ddlGrupoTarifa").popover('show'); }, 100)

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
                        //exibeError($('#ddlGrupoTarifa'), true);
                        //exibeCampoObrigatorio($('#ddlGrupoTarifa'), "O Grupo Tarifa <b>" + $("#ddlGrupoTarifa option:selected").text() + "</b> não possuem Tarifas cadastradas");

                        var htmlGrupo = "<div style='width:433px; font-size: 13px' class='alert alert-info'>";
                        htmlGrupo += "O Grupo Tarifário <b>" + $("#ddlGrupoTarifa option:selected").text() + "</b> não possuem Tarifas cadastradas!"
                        htmlGrupo += "</div>";

                        $('#ddlGrupoTarifa').popover('destroy');
                        $('#ddlGrupoTarifa').popover({ template: '<div><div class="popover-content"></div></div>', trigger: "hover", content: htmlGrupo, placement: "bottom", html: true });
                        setTimeout(function () { $("#ddlGrupoTarifa").popover('show'); }, 100)
                    }
                }
            });

        }

        function carregaListaBanco() {

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Produto.aspx/ObterListaBanco',
                //data: param,
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        $('#ddlBanco').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));

                        $.each(jsonResult.Resultado, function (index, item) {
                            $('#ddlBanco').append($('<option>', { text: "(" + item.Valor + ") " + item.Nome, value: item.Valor }, '</option>'));

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
                        exibeError($('#ddlBanco'), true);
                    }

                },
                error: function (response) {
                    //$("#modalErro").modal("show");
                    exibeError($('#ddlBanco'), true);
                    window.location.href = "../../Erro.aspx";
                }
            });
        }

        function carregaTipoOperacaoCartao() {

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Produto.aspx/ObterListaTipoCartao',
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        //$('#ddlTipoOperacaoCartao').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));
                        $.each(jsonResult.Resultado, function (index, item) {
                            $('#ddlTipoOperacaoCartao').append($('<option>', { value: item.Valor, text: item.Nome }, '</option>'));

                        })

                        verificaLimiteConta();

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
                        exibeError($('#ddlTipoOperacaoCartao'), true);
                    }
                },
                error: function (response) {
                    //$("#modalErro").modal("show");
                    exibeError($('#ddlTipoOperacaoCartao'), true);
                    window.location.href = "../../Erro.aspx";
                }
            });

        }

        function carregaStatusCartao() {

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Produto.aspx/ObterListaStatusCartao',
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
                url: 'Produto.aspx/ObterListaTipoBloqueioCartao',
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

        function carregaVencimentoEmissor() {

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Produto.aspx/ObterVencimentoEmissor',
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado != null) {

                        var dias = jsonResult.Resultado.DiasRenovacaCartao;
                        var vencimento = new Date();
                        vencimento.setDate(vencimento.getDate() + dias);
                        $('#txtDataVencimentoEmissor').val(toFormatString(vencimento));

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
                        exibeError($('#txtDataVencimentoEmissor'), true);
                    }
                },
                error: function (response) {
                    //$("#modalErro").modal("show");
                    exibeError($('#txtDataVencimentoEmissor'), true);
                    window.location.href = "../../Erro.aspx";
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

    </script>
</head>
<body class="fadeIn">
    <form id="form1" autocomplete="off" runat="server">
    <asp:ScriptManager runat="server">
    </asp:ScriptManager>
    <asp:HiddenField ID="hdnCodConta" runat="server" Value="" />
    <asp:HiddenField ID="hdnUsuario" runat="server" Value="" />
    <div class="container">
        <div class="content">
            <div class="row">
                <div class="col-md-12">
                    <h3 id="divTitulo" class="page-header">
                        Inclusão de Cartão</h3>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel-body">
            <div class="row row-margin">
                <div id="dados-cartao" class="panel panel-default">
                    <div class="panel-heading panel-font">
                        Dados do Cartão
                    </div>
                    <div class="panel-body">
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="lblCpfCnpj" runat="server" Text="CPF/CNPJ:" CssClass="control-label"></asp:Label>
                                    <asp:Label ID="lblCpfCnpjTitular" runat="server" CssClass="control-label-box-default"> </asp:Label>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="lbNome" runat="server" Text="Nome:" CssClass="control-label"></asp:Label>
                                    <asp:Label ID="lblNomeTitular" runat="server" CssClass="control-label-box-default"> </asp:Label>
                                </div>
                            </div>
                        </div>
                        <hr />
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="lblRenda" runat="server" Text="Renda Mensal:" CssClass="control-label"></asp:Label>
                                    <div class="input-group">
                                        <span class="input-group-addon">R$</span>
                                        <asp:TextBox ID="txtRendaMensal" runat="server" MaxLength="15" Width="157" placeholder="Renda mensal"
                                            data-required="true" CssClass="form-control input-money" disabled></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label7" runat="server" Text="Limite Disponível da Conta:" CssClass="control-label"></asp:Label>
                                    <div class="input-group">
                                        <span class="input-group-addon">R$</span>
                                        <asp:TextBox ID="txtLimiteConta" runat="server" MaxLength="15" Width="157" placeholder="Limite total disponível da conta"
                                            data-required="true" CssClass="form-control input-money" disabled></asp:TextBox>
                                        <span class="input-group-btn" style='display: inline' data-toggle='tooltip' data-placement='right'
                                            title='alterar limites'><a id="btnLimite" href="#" class="btn btn-info" style="height: 34px">
                                                <i class="fa fa-usd"></i></a></span>
                                    </div>
                                </div>
                            </div>
                            <div id="divLimiteProduto" class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label6" runat="server" Text="Limite do Produto:" CssClass="control-label"></asp:Label>
                                    <div class="input-group">
                                        <span class="input-group-addon">R$</span>
                                        <asp:TextBox ID="txtLimiteProduto" runat="server" MaxLength="15" Width="157" placeholder="Limite do produto"
                                            data-required="true" CssClass="form-control input-money"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div id="divLimiteIndisponivel" class="alert alert-danger alert-dismissable text-center display-none">
                            <button type="button" class="close" data-dismiss="alert" aria-hidden="true">
                                ×</button>
                            Limite da conta indisponível<br>
                            <a id="btnLimiteIndisponivel" href="#" class="alert-link">Alterar Limites</a>
                        </div>
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label44" runat="server" Text="Tipo Operação:" CssClass="control-label"></asp:Label>
                                    <asp:DropDownList runat="server" ID="ddlTipoOperacaoCartao" data-required="true"
                                        CssClass="form-control" Width="200">
                                        <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label8" runat="server" Text="Bandeira:" CssClass="control-label"></asp:Label>
                                    <asp:DropDownList runat="server" ID="ddlBandeira" data-required="true" CssClass="form-control"
                                        Width="200">
                                        <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label25" runat="server" Text="Produto:" CssClass="control-label"></asp:Label>
                                    <asp:HiddenField ID="hdnListaProdutos" runat="server" Value="" />
                                    <asp:DropDownList runat="server" ID="ddlProduto" data-required="true" CssClass="form-control"
                                        Width="200">
                                    </asp:DropDownList>
                                </div>
                            </div>
                        </div>
                        <div id="divLimitesProduto" class="row display-none">
                            <div class="col-md-6 bs-glyphicons">
                                <asp:Label ID="Label5" runat="server" Text="Limites do Produto:" CssClass="control-label"></asp:Label>
                                <asp:HiddenField ID="hdnListaLimites" runat="server" Value="" />
                                <table id="table-limites" class="table table-hover">
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                            <div class="col-md-3">
                                <div class="form-group">
                                    <asp:Label ID="Label27" runat="server" Text="Grupo Tarifário:" CssClass="control-label"></asp:Label>
                                    <asp:DropDownList runat="server" ID="ddlGrupoTarifa" data-required="true" Width="200"
                                        CssClass="form-control">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-md-3 display-none" id="divVencimentoGrupoTarifario">
                                <div class="form-group">
                                    <asp:Label ID="Label43" runat="server" Text="Vencimento Tarifário:" CssClass="control-label"></asp:Label>
                                    <asp:TextBox ID="txtVencimentoGrupoTarifario" runat="server" placeholder="Data do Vencimento"
                                        Width="200" data-required="true" CssClass="form-control input-date"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label22" runat="server" Text="Possui Débito Automático:" CssClass="control-label"></asp:Label>
                                    <asp:DropDownList runat="server" ID="ddlDebAutomatico" Width="200" CssClass="form-control"
                                        data-required="true">
                                        <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                        <asp:ListItem Text="Sim" Value="1" />
                                        <asp:ListItem Text="Não" Value="0" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                        </div>
                        <div class="row display-none" id="divConta">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label20" runat="server" Text="Banco:" CssClass="control-label"></asp:Label>
                                    <asp:DropDownList runat="server" ID="ddlBanco" CssClass="form-control" data-required="true">
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label9" runat="server" Text="Agência:" CssClass="control-label"></asp:Label>
                                    <div class="input-group">
                                        <asp:TextBox ID="txtAgencia" runat="server" MaxLength="10" placeholder="Agência"
                                            data-required="true" Width="100" CssClass="form-control input-numeric"></asp:TextBox>
                                        <asp:TextBox ID="txtAgenciaDv" runat="server" MaxLength="5" placeholder="DV" data-required="true"
                                            Width="50" CssClass="form-control input-numeric"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label10" runat="server" Text="Conta Corrente:" CssClass="control-label"></asp:Label>
                                    <div class="input-group">
                                        <asp:TextBox ID="txtContaCorrente" runat="server" MaxLength="20" placeholder="Conta"
                                            data-required="true" Width="100" CssClass="form-control input-numeric"></asp:TextBox>
                                        <asp:TextBox ID="txtContaCorrenteDv" runat="server" MaxLength="5" placeholder="DV"
                                            data-required="true" Width="50" CssClass="form-control input-numeric"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <div class="form-inline">
                                        <asp:Label ID="Label23" runat="server" Text="Dia do Vencimento / Faturamento:" CssClass="control-label"></asp:Label>
                                        <asp:Label ID="Label28" runat="server" Text="" CssClass="control-label"></asp:Label>
                                    </div>
                                    <div class="form-inline">
                                        <asp:DropDownList runat="server" ID="ddlDiaVencimento" Width="120" data-required="true"
                                            CssClass="form-control">
                                            <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                        </asp:DropDownList>
                                        <asp:TextBox ID="txtDiaFaturamento" runat="server" MaxLength="2" Width="60" data-required="true"
                                            CssClass="form-control" disabled></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label35" runat="server" Text="Vencimento Cartão Emissor:" CssClass="control-label"></asp:Label>
                                    <asp:HiddenField ID="hdnDataVencimentoEmissor" runat="server" Value="" />
                                    <asp:TextBox ID="txtDataVencimentoEmissor" runat="server" placeholder="Data do Vencimento"
                                        Width="200" data-required="true" CssClass="form-control input-date" Enabled="false"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-md-4 display-none" id="divDataVencimentoBandeira">
                                <div class="form-group">
                                    <asp:Label ID="Label36" runat="server" Text="Vencimento Cartão Bandeira:" CssClass="control-label"></asp:Label>
                                    <asp:HiddenField ID="hdnDataVencimentoBandeira" runat="server" Value="" />
                                    <asp:TextBox ID="txtDataVencimentoBandeira" runat="server" placeholder="Data do Vencimento"
                                        Enabled="false" Width="200" data-required="true" CssClass="form-control input-date"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label15" runat="server" Text="Nome do Cliente no Cartão:" CssClass="control-label"></asp:Label>
                                    <asp:TextBox ID="txtNomeCartao" runat="server" MaxLength="25" placeholder="Nome do cliente no cartão"
                                        data-required="true" CssClass="form-control input-uppercase"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        <div class="row" style="margin-top: 5px">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label24" runat="server" Text="Bloqueado Exterior:" CssClass="control-label"></asp:Label>
                                    <asp:DropDownList ID="ddlBloqueadoExterior" runat="server" data-required="true" CausesValidation="True"
                                        CssClass="form-control" Width="200px">
                                        <asp:ListItem Text="Selecione" Value="" />
                                        <asp:ListItem Text="Sim" Value="1" Selected="True" />
                                        <asp:ListItem Text="Não" Value="0" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-md-4 display-none" id="divFaixaIniBloqExt" runat="server">
                                <div class="form-group">
                                    <asp:Label ID="Label37" runat="server" Text="Data Início da Vigência:" CssClass="control-label"></asp:Label>
                                    <asp:TextBox ID="txtFaixaIniBloqExt" runat="server" MaxLength="10" data-required="true"
                                        placeholder="Data início" CssClass="form-control input-date" Width="200px"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-md-4" id="divFaixaFimBloqExt" runat="server" style="display: none">
                                <div class="form-group">
                                    <asp:Label ID="Label40" runat="server" Text="Data Fim da Vigência:" CssClass="control-label"></asp:Label>
                                    <asp:TextBox ID="txtFaixaFimBloqExt" runat="server" MaxLength="10" data-required="true"
                                        placeholder="Data fim" CssClass="form-control input-date" Width="200px"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        <div class="row" style="margin-top: 5px">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label41" runat="server" Text="Status do Cartão:" CssClass="control-label"></asp:Label>
                                    <asp:DropDownList ID="ddlStatusCartao" runat="server" CausesValidation="True" data-required="true"
                                        CssClass="form-control" Width="200px" disabled>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-md-4" id="divTipoBloqueio" runat="server">
                                <div class="form-group">
                                    <asp:Label ID="Label42" runat="server" Text="Tipo do Bloqueio:" CssClass="control-label"></asp:Label>
                                    <asp:DropDownList ID="ddlTipoBloqueio" runat="server" CausesValidation="True" data-required="true"
                                        CssClass="form-control" Width="200px" disabled>
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <br />
                        </div>
                    </div>
                </div>
            </div>
            <div class="row align-center">
                <asp:LinkButton ID="btnConfirmar" CssClass="btn btn-primary" runat="server" OnClientClick="javascript:return validaFormulario();"
                    OnClick="btnConfirmar_Click">Confirmar <i class="fa fa-check"></i></asp:LinkButton>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <a type="button" href="MenuTitular.aspx" id="btnVoltar" runat="server" class="btn btn-link">
                        Voltar</a>
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
                        Cliente Titular</h4>
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
    </form>
</body>
<script language="javascript" type="text/javascript">

    var operacao = $('[id$=hdnOperacao]').val();
    var conta = $('[id$=hdnCodConta]').val();
    var Usuario = $('[id$=hdnUsuario]').val().toUpperCase();

    if (operacao == "Erro") {
        $("#modalErro").modal("show");
    }

    $('[id$=hdnOperacao]').val('');
    $("#btnLimite").attr("href", "Limite.aspx?conta=" + conta);

    verificaLimiteConta();

</script>
</html>

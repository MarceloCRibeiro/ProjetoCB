<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeFile="Cartao.aspx.cs"
    Inherits="Cartao" %>
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

    <link rel="stylesheet" type="text/css" href="../../css/cssCartao.css" />

    <script language="javascript" type="text/javascript" src="../../js/jquery-3.1.1.min.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/jquery.mask.min.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/jquery.maskMoney.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/bootstrap.js"></script>
    <%--<script language="javascript" type="text/javascript" src="../../js/bootstrap-checkbox.min.js"></script>--%>
    <script language="javascript" type="text/javascript" src="../../js/metisMenu/metisMenu.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/sb-admin-2.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/default.js"></script>
    
    <script language="javascript" type="text/javascript">
        var EventBack_carregaListaMotivoStatusCartao = false;

        //var ArrayStatusCartao = {};
        var ArrayVencimento = {};
        var ArrayFaturamento = {};

        var UsuarioTitular = "";
        var OperacaoCartao = "";
        var CartaoSelecionado = null;

        var MotivoSegundaVia = null;
        var MotivoStatusCartao = null;

        $(document).ready(function () {
            //carregaStatusCartao();
            carregaListaVencimento();

            if (request("via2") != "" && request("via2") == "true")
                OperacaoCartao = "Alteracao2Via";
            else
                OperacaoCartao = "AlteracaoStatus";

            if (OperacaoCartao == "Alteracao2Via") {
                $("#divTitulo").text('Solicitar Segunda Via de Cartão')
                $('#divConfirmarVia2').show();
            }
            else {
                obtemMotivoStatusCartaoAtivo()
                obtemMotivoStatusCartaoExtravio()

                $("#divTitulo").text('Alterar Status de Cartão')
                $('#divConfirmarStatus').show();
            }

            $('#btnMotivoEmbossing, #btnMotivoPerda, #btnMotivoRoubo, #btnMotivoDefeito, #btnMotivoExtravio').click(function () {
                var opt = this.id;

                $("[name=optMotivo]").closest('label').removeClass('active');
                $("[name=optMotivo]").closest('label').removeClass('btn-primary');
                $("[name=optMotivo]").closest('label').removeClass('btn-danger');
                $("[name=optMotivo]").closest('label').addClass('btn-default');

                if (opt == "btnMotivoEmbossing") {
                    $("input[name=optMotivo][id=optEmbossing]").prop('checked', true);
                    $("input[name=optMotivo][id=optEmbossing]").closest('label').removeClass('btn-default');
                    $("input[name=optMotivo][id=optEmbossing]").closest('label').addClass('btn-primary');
                }
                else if (opt == "btnMotivoPerda") {
                    $("input[name=optMotivo][id=optPerda]").prop('checked', true);
                    $("input[name=optMotivo][id=optPerda]").closest('label').removeClass('btn-default');
                    $("input[name=optMotivo][id=optPerda]").closest('label').addClass('btn-danger');
                }
                else if (opt == "btnMotivoRoubo") {
                    $("input[name=optMotivo][id=optRoubo]").prop('checked', true);
                    $("input[name=optMotivo][id=optRoubo]").closest('label').removeClass('btn-default');
                    $("input[name=optMotivo][id=optRoubo]").closest('label').addClass('btn-danger');
                }
                else if (opt == "btnMotivoDefeito") {
                    $("input[name=optMotivo][id=optDefeito]").prop('checked', true);
                    $("input[name=optMotivo][id=optDefeito]").closest('label').removeClass('btn-default');
                    $("input[name=optMotivo][id=optDefeito]").closest('label').addClass('btn-primary');
                }
                else if (opt == "btnMotivoExtravio") {
                    $("input[name=optMotivo][id=optExtravio]").prop('checked', true);
                    $("input[name=optMotivo][id=optExtravio]").closest('label').removeClass('btn-default');
                    $("input[name=optMotivo][id=optExtravio]").closest('label').addClass('btn-primary');
                }

            });

            //$('#btnStatusAtivar, #btnStatusBloquear, #btnStatusCancelar').click(function () {
            $("#btnStatusAtivar, #btnStatusBloquear, #btnStatusCancelar, #btnStatusBloqueadoExtravio").off("click").on("click", function () {
                var opt = this.id;

                $("[name=optMotivoStatus]").closest('label').removeClass('active');
                $("[name=optMotivoStatus]").closest('label').removeClass('btn-success');
                $("[name=optMotivoStatus]").closest('label').removeClass('btn-primary');
                $("[name=optMotivoStatus]").closest('label').removeClass('btn-danger');
                $("[name=optMotivoStatus]").closest('label').addClass('btn-default');

                if (opt == "btnStatusAtivar") {
                    $("input[name=optMotivoStatus][id=optAtivar]").prop('checked', true);
                    $("input[name=optMotivoStatus][id=optAtivar]").closest('label').removeClass('btn-default');
                    $("input[name=optMotivoStatus][id=optAtivar]").closest('label').addClass('btn-success');

                    $('#divMotivo').slideUp('slow');

                }
                else if (opt == "btnStatusBloquear") {
                    $("input[name=optMotivoStatus][id=optBloquear]").prop('checked', true);
                    $("input[name=optMotivoStatus][id=optBloquear]").closest('label').removeClass('btn-default');
                    $("input[name=optMotivoStatus][id=optBloquear]").closest('label').addClass('btn-primary');

                    if (!EventBack_carregaListaMotivoStatusCartao) {
                        var valor = $('#optBloquear').val();
                        carregaListaMotivoStatusCartao(valor)
                    }

                }
                else if (opt == "btnStatusCancelar") {
                    $("input[name=optMotivoStatus][id=optCancelar]").prop('checked', true);
                    $("input[name=optMotivoStatus][id=optCancelar]").closest('label').removeClass('btn-default');
                    $("input[name=optMotivoStatus][id=optCancelar]").closest('label').addClass('btn-danger');

                    if (!EventBack_carregaListaMotivoStatusCartao) {
                        var valor = $('#optCancelar').val();
                        carregaListaMotivoStatusCartao(valor)
                    }

                }
                else if (opt == "btnStatusBloqueadoExtravio") {
                    $("input[name=optMotivoStatus][id=optBloqueadoExtravio]").prop('checked', true);
                    $("input[name=optMotivoStatus][id=optBloqueadoExtravio]").closest('label').removeClass('btn-default');
                    $("input[name=optMotivoStatus][id=optBloqueadoExtravio]").closest('label').addClass('btn-primary');

                    $('#divMotivo').slideUp('slow');

                }

            });

            $("#ddlCartao").click(function () {
                setTimeout(function () { $('#ddlCartaoToggle').dropdown('toggle'); }, 50);

            });

            $("#btnNovaSenha").click(function () {
                $(window).scrollTop(0);
                $(window.parent).scrollTop(0)
            });

            $("#btnConfirmarVia2").click(function () {
                $(window).scrollTop(0);
                $(window.parent).scrollTop(0)
            });
            
            $(".dropdown-menu a.cart").click(function () {
                $('#divDadosVia2').slideUp();
                $('#divDadosStatus').slideUp();
                $('#divDadosCartao').slideUp();

                if ($(this).closest('ul').attr('class').indexOf('ul-primary-level') > 0)
                    $('#ddlCartao').html("<i class='fa fa-credit-card-alt fa-fw'></i> " + $(this).text())
                else
                    $('#ddlCartao').html("<i class='fa fa-credit-card fa-fw'></i> " + $(this).text())

                var codCartao = $(this).attr('data-cod_cartao');
                $('input#hdnCodCartao').val(codCartao);

                var contaProduto = ObtemContaProduto(codCartao);
                CartaoSelecionado = ObtemCartao(codCartao);
                
                $('#txtNomeCartao').val(CartaoSelecionado.NomeCartao);

                if (CartaoSelecionado.LimiteProduto != null) {
                    $('#lblLimiteProduto').text('R$ ' + retornaValor(CartaoSelecionado.LimiteProduto));
                    $('#divLimiteProduto').show();
                }
                else {
                    $('#lblLimiteProduto').text('');
                    $('#divLimiteProduto').hide();
                }

                //$('#lblStatusCartao').text(ArrayStatusCartao[CartaoSelecionado.CodStatusCartao]);
                $('#lblStatusCartao').text(CartaoSelecionado.StatusCartao);
                if (CartaoSelecionado.StatusCartao != 'Ativo') {
                    $('#lblMotivoCartao').text(CartaoSelecionado.MotivoCartao);
                    $('#divMotivoCartao').show();
                }
                else {
                    $('#lblMotivoCartao').text('');
                    $('#divMotivoCartao').hide();
                }


                $('#lblVencimento').text(ArrayVencimento[contaProduto.CodVencimento]);
                $('#lblFaturamento').text(ArrayFaturamento[contaProduto.CodVencimento]);

                if (OperacaoCartao == "Alteracao2Via") {
                    
                    $("[name=optMotivo]").closest('label').removeClass('active');
                    $("[name=optMotivo]").closest('label').removeClass('btn-primary');
                    $("[name=optMotivo]").closest('label').removeClass('btn-danger');
                    $("[name=optMotivo]").closest('label').addClass('btn-default');
                    $("input[name=optMotivo]").prop('checked', false);

                    //$('#btnConfirmarVia2').removeClass('disabled');
                    $('#btnConfirmarVia2').removeAttr('disabled');
                    $('#btnNovaSenha').removeAttr('disabled');

                    if (CartaoSelecionado.StatusCartao == "Ativo") {

                        $('#divDadosVia2').slideDown();

                        $("#btnMotivoEmbossing").show();
                        $("#btnMotivoPerda").show();
                        $("#btnMotivoRoubo").show();
                        $("#btnMotivoDefeito").show();
                        $("#btnMotivoExtravio").show();

                    }
                    else if (CartaoSelecionado.StatusCartao == "Bloqueado") {

                        $('#divDadosVia2').slideDown();

                        $("#btnMotivoEmbossing").show();
                        $("#btnMotivoPerda").show();
                        $("#btnMotivoRoubo").show();
                        $("#btnMotivoDefeito").show();
                        
                        if (CartaoSelecionado.MotivoCartao == "Entrega") {
                            $("#btnMotivoExtravio").show();
                        }
                        else {
                            $("#btnMotivoExtravio").hide();
                        }
                    }
                    else if (CartaoSelecionado.StatusCartao == "Cancelado") {
                        $('#divDadosVia2').slideUp();

                        $("#btnMotivoEmbossing").hide();
                        $("#btnMotivoPerda").hide();
                        $("#btnMotivoRoubo").hide();
                        $("#btnMotivoDefeito").hide();
                        $("#btnMotivoExtravio").hide();

                        $("#btnConfirmarVia2").attr("disabled", "disabled");
                        $("#btnNovaSenha").attr("disabled", "disabled");
                        
                    }

                }
                else {

                    $('#divMotivo').slideUp('slow');

                    $("[name=optMotivoStatus]").closest('label').removeClass('active');
                    $("[name=optMotivoStatus]").closest('label').removeClass('btn-success');
                    $("[name=optMotivoStatus]").closest('label').removeClass('btn-primary');
                    $("[name=optMotivoStatus]").closest('label').removeClass('btn-danger');
                    $("[name=optMotivoStatus]").closest('label').addClass('btn-default');
                    $("input[name=optMotivoStatus]").prop('checked', false);

                    //function () {
                    //    if ($('#ddlStatusCartao option').length > 1) {
                    //        $.each($('#ddlStatusCartao option'), function (index, item) {
                    //            if (item.value == CartaoSelecionado.CodStatusCartao) {
                    //                $(item).attr('disabled', 'disabled')
                    //            }
                    //        })
                    //        clearInterval(intervalStatus);
                    //    }
                    //}, 100);

                    //$('#btnConfirmarStatus').removeClass('disabled');
                    $('#btnConfirmarStatus').removeAttr('disabled');

                    if (CartaoSelecionado.StatusCartao == "Ativo") {
                        $('#divDadosStatus').slideDown();

                        $("#btnStatusBloquear").show();
                        $("#btnStatusCancelar").show();
                        $("#btnStatusBloqueadoExtravio").show();
                        $("#btnStatusAtivar").hide();

                    }
                    else if (CartaoSelecionado.StatusCartao == "Bloqueado") {
                        $('#divDadosStatus').slideDown();

                        $("#btnStatusAtivar").show();
                        $("#btnStatusCancelar").show();
                        $("#btnStatusBloquear").hide();

                        if (CartaoSelecionado.MotivoCartao == "Extravio") {
                            $("#btnStatusBloqueadoExtravio").hide();
                        }
                        else {
                            $("#btnStatusBloqueadoExtravio").show();
                        }

                    }
                    else if (CartaoSelecionado.StatusCartao == "Cancelado") {
                        $('#divDadosStatus').slideUp();
                        
                        $("#btnStatusAtivar").hide();
                        $("#btnStatusCancelar").hide();
                        $("#btnStatusBloquear").hide();
                        $("#btnStatusBloqueadoExtravio").hide();

                        $("#btnConfirmarStatus").attr("disabled", "disabled");

                    }
                }

                $('#divDadosCartao').slideDown();

            });

            $("#ddlMotivoStatusCartao").change(function () {
                var valor = $('#ddlMotivoStatusCartao option:selected').val();

                if (valor != "")
                    $('#btnConfirmarStatus').removeAttr('disabled');
                else
                    $("#btnConfirmarStatus").attr("disabled", "disabled");
            });

        });

        //function carregaStatusCartao() {
        //    ArrayStatusCartao = {};
        //    $.ajax({
        //        type: "POST",
        //        contentType: "application/json; charset=utf-8",
        //        url: 'Titular.aspx/ObterListaStatusCartao',
        //        dataType: "json",
        //        async: true,
        //        success: function (response) {
        //            var jsonResult = response.d;
        //            if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {
        //                $.each(jsonResult.Resultado, function (index, item) {
        //                    $('#ddlStatusCartao').append($('<option>', { value: item.Valor, text: item.Nome }, '</option>'));
        //                    ArrayStatusCartao[item.Valor] = item.Nome
        //                })
        //            }
        //        },
        //        error: function (response) {
        //            window.location.href = "../../Erro.aspx";
        //        }
        //    });
        //}

        function carregaListaMotivoStatusCartao(valor) {

            EventBack_carregaListaMotivoStatusCartao = true;

            $('#ddlMotivoStatusCartao').empty();
            exibeError($('#ddlMotivoStatusCartao'), false);

            $('#divMotivo').slideUp('slow');

            if (valor === undefined)
                valor = null;

            var param = JSON.stringify({
                codStatusCartao: valor
            });

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Cartao.aspx/ObterListaMotivoStatusCartao',
                data: param,
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {
                        MotivoStatusCartao = jsonResult.Resultado;

                        $('#ddlMotivoStatusCartao').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));
                        $.each(jsonResult.Resultado, function (index, item) {
                            $('#ddlMotivoStatusCartao').append($('<option>', { value: item.Valor, text: item.Nome }, '</option>'));
                        })
                    }

                    $('#divMotivo').slideDown('slow');

                },
                error: function (response) {
                    window.location.href = "../../Erro.aspx";
                },
                complete: function (response) {
                    EventBack_carregaListaMotivoStatusCartao = false;
                }

            });

        }

        function obtemMotivoStatusCartaoAtivo() {

            var param = JSON.stringify({
                codStatusCartao: 1 
            });

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Cartao.aspx/ObterListaMotivoStatusCartao',
                data: param,
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {
                        $("#optAtivar").val(obtemValor('Ativo', jsonResult.Resultado));
                    }

                },
                error: function (response) {
                    window.location.href = "../../Erro.aspx";
                }
            });

        }

        function obtemMotivoStatusCartaoExtravio() {

            var param = JSON.stringify({
                codStatusCartao: 2 // bloqueio
            });

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Cartao.aspx/ObterListaMotivoStatusCartao',
                data: param,
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {
                        $("#optBloqueadoExtravio").val(obtemValor('Extravio', jsonResult.Resultado));
                    }

                },
                error: function (response) {
                    window.location.href = "../../Erro.aspx";
                }
            });

        }

        function carregaListaVencimento() {

            ArrayVencimento = {};
            ArrayFaturamento = {};

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Titular.aspx/ObterDadosVencimentoFatura',
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        $.each(jsonResult.Resultado, function (index, item) {

                            ArrayVencimento[item.CodVencimento] = item.DiaVencimento
                            ArrayFaturamento[item.CodVencimento] = item.DiaFaturamento

                        })
                    }
                    
                },
                error: function (response) {
                    //$("#modalErro").modal("show");
                    exibeError($('#ddlDiaVencimento'), true);
                    window.location.href = "../../Erro.aspx";
                }
            });

        }

        function VerificarAtualizarMotivoStatusCartao() {
            var ret = false;

            var param = JSON.stringify({
                codCartao: $('input#hdnCodCartao').val(),
                codMotivoStatusCartao: $('input#hdnCodMotivoStatusCartao').val()
            });

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Cartao.aspx/VerificarAtualizarMotivoStatusCartao',
                data: param,
                dataType: "json",
                async: false,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado) {
                        ret = true;
                    }
                    else {
                        $(window).scrollTop(0);
                        $(window.parent).scrollTop(0)

                        $("#modalErro").modal("show");
                        //$("#MensagemErro").text('Operação não autorizada!\nPor favor verifique os parâmetros de permissão!');
                        $("#MensagemErro").html('Operação não autorizada!<br>Por favor verifique os parâmetros de permissão!');
                    }

                },
                error: function (response) {
                    window.location.href = "../../Erro.aspx";
                }
            });

            return ret;
        }

        function VerificarSolicitarSegundaVia() {
            var ret = false;

            var param = JSON.stringify({
                codCartao: $('input#hdnCodCartao').val(),
                codMotivo: $('input#hdnCodMotivoStatusCartao').val()
            });

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Cartao.aspx/VerificarSolicitarSegundaVia',
                data: param,
                dataType: "json",
                async: false,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado) {
                        ret = true;
                    }
                    else {
                        $(window).scrollTop(0);
                        $(window.parent).scrollTop(0)

                        $("#modalErro").modal("show");
                        //$("#MensagemErro").text('Operação não autorizada!\nPor favor verifique os parâmetros de permissão!');
                        $("#MensagemErro").html('Operação não autorizada!<br>Por favor verifique os parâmetros de permissão!');
                    }

                },
                error: function (response) {
                    window.location.href = "../../Erro.aspx";
                }
            });

            return ret;

        }
        
        // método responsável por validar os campos do form
        function validaFormulario() {

            if (CartaoSelecionado != null && CartaoSelecionado.StatusCartao == "Cancelado") {
                $("#modalErro").modal("show");
                $("#MensagemErro").text('Este cartão está cancelado!');
                return false;
            }

            if (!(CartaoSelecionado.CodEmiteCartao == null || CartaoSelecionado.CodEmiteCartao == 0 || CartaoSelecionado.CodEmiteCartao == 3)) {
                $("#modalErro").modal("show");
                $("#MensagemErro").text('Já existe uma via a ser emitida deste cartão!');
                return false;
            }
            
            if (CartaoSelecionado.StatusCartao == "Bloqueado") {

                if (CartaoSelecionado.MotivoCartao.toUpperCase() != "ENTREGA" && CartaoSelecionado.MotivoCartao.toUpperCase() != "EMBOSSING" && CartaoSelecionado.MotivoCartao.toUpperCase() != "DEFEITO" && CartaoSelecionado.MotivoCartao.toUpperCase() != "EXTRAVIO") {
                    $("#modalErro").modal("show");
                    $("#MensagemErro").text('Este cartão está cancelado!');
                    return false;
                }

            }

            if (!isNullOrEmpty($('input#hdnCodCartao').val())) {

                if (OperacaoCartao == "Alteracao2Via") {

                    if ($("[name=optMotivo]:checked").val() === undefined || $("[name=optMotivo]:checked").val() == null) {
                        $(window).scrollTop(0);
                        $(window.parent).scrollTop(0)

                        $("#modalErro").modal("show");
                        $("#MensagemErro").text('Informe o motivo da solicitação de segunda via!');
                        return false;
                    }

                    if ($('#txtNomeCartao').val().trim() == "") {
                        exibeCampoObrigatorio($('#txtNomeCartao'));
                        $('#txtNomeCartao').focus();
                        return false;
                    }

                    $('input#hdnCodMotivoStatusCartao').val($("[name=optMotivo]:checked").val());

                    if (!VerificarSolicitarSegundaVia())
                        return false

                }
                else if (OperacaoCartao == "AlteracaoStatus") {

                    if ($("[name=optMotivoStatus]:checked").val() === undefined || $("[name=optMotivoStatus]:checked").val() == null) {

                        $(window).scrollTop(0);
                        $(window.parent).scrollTop(0)

                        $("#modalErro").modal("show");
                        $("#MensagemErro").text('Informe o status desejado!');
                        return false;
                    }

                    if ($("input[name=optMotivoStatus][id=optBloquear]").prop('checked') || $("input[name=optMotivoStatus][id=optCancelar]").prop('checked')) {

                        if ($('#ddlMotivoStatusCartao')[0].selectedIndex < 1) {
                            exibeCampoObrigatorio($('#ddlMotivoStatusCartao'));
                            $('#ddlMotivoStatusCartao').focus();
                            return false;
                        }

                        $('input#hdnCodMotivoStatusCartao').val($('#ddlMotivoStatusCartao').val());

                    }
                    else {
                        $('input#hdnCodMotivoStatusCartao').val($("[name=optMotivoStatus]:checked").val());

                    }

                    if (!VerificarAtualizarMotivoStatusCartao())
                        return false

                }

                $('input#hdnNovaSenha').val('');
                $(".loading").fadeIn("slow");
                return true;

            }

            return false;
        }

        function validaNovaSenha() {
            if (!isNullOrEmpty($('input#hdnCodCartao').val())) {
                $(".loading").fadeIn("slow");
                $('input#hdnNovaSenha').val($('input#hdnCodCartao').val());
                return true;
            }

            return false;
        }

        function ObtemCartao(codCartao) {
            var cartao = null;

            var cartaoTitular = UsuarioTitular.Conta.ContaProduto.filter(function (itemTitular) {
                if (itemTitular.Cartao.CodCartao == codCartao) {
                    cartao = itemTitular.Cartao;
                    return;
                }
                else {
                    if (itemTitular.Cartao.Adicional != null) {
                        var cartaoAdicional = itemTitular.Cartao.Adicional.filter(function (itemAdicional) {
                            if (itemAdicional.CartaoAdicional.CodCartao == codCartao) {
                                cartao = itemAdicional.CartaoAdicional;
                                return;
                            }
                        });
                    }
                }
            });

            return cartao;

        }

        function ObtemContaProduto(codCartao) {
            var contaProduto = null;

            if (codCartao === undefined)
                codCartao = $('#ddlCartao option:selected').val();

            var cartaoTitular = UsuarioTitular.Conta.ContaProduto.filter(function (itemTitular) {
                if (itemTitular.Cartao.CodCartao == codCartao) {
                    contaProduto = itemTitular;
                    return;
                }
                else {
                    if (itemTitular.Cartao.Adicional != null) {
                        var cartaoAdicional = itemTitular.Cartao.Adicional.filter(function (itemAdicional) {
                            if (itemAdicional.CartaoAdicional.CodCartao == codCartao) {
                                contaProduto = itemTitular;
                                return;
                            }
                        });
                    }
                }
            });

            return contaProduto;

        }

        function ObtemCartaoTitular(codCartao) {

            if (codCartao === undefined)
                codCartao = $('#ddlCartao option:selected').val();

            var cartaoTitular = UsuarioTitular.Conta.ContaProduto.filter(function (item) {
                if (item.Cartao.CodCartao == codCartao) {
                    return item;
                }
            });

            return cartaoTitular[0].Cartao;

        }

//        function ObtemContaProduto(codCartao) {

//            if (codCartao === undefined)
//                codCartao = $('#ddlNumeroCartaoTitular option:selected').val();

//            var cartaoTitular = UsuarioTitular.Conta.ContaProduto.filter(function (item) {
//                if (item.Cartao.CodCartao == codCartao) {
//                    return item;
//                }
//            });

//            return cartaoTitular[0];

//        }

        function ObtemCartaoAdicional(codCartaoAdicional) {

            var cartaoTitular = ObtemCartaoTitular();

            if (cartaoTitular.Adicional != null) {

                if (codCartaoAdicional === undefined)
                    codCartaoAdicional = $('#ddlNumeroCartaoAdicional option:selected').val();

                var cartaoAdicional = cartaoTitular.Adicional.filter(function (item) {
                    if (item.CartaoAdicional.CodCartao == codCartaoAdicional) {
                        return item;
                    }
                });

                return cartaoAdicional[0].CartaoAdicional;
            }

            return null;
        }

    </script>
</head>
<body class="fadeIn">
    <form id="form1" autocomplete="off" runat="server">
    <asp:ScriptManager runat="server">
    </asp:ScriptManager>
    <asp:HiddenField ID="hdnOperacao" runat="server" Value="" />
    <asp:HiddenField ID="hdnTitular" runat="server" Value="" />
    <asp:HiddenField ID="hdnMotivo" runat="server" Value="" />
    <asp:HiddenField ID="hdnCodCartao" runat="server" Value="" />
    <asp:HiddenField ID="hdnCodMotivoStatusCartao" runat="server" Value="" />
    <asp:HiddenField ID="hdnNovaSenha" runat="server" Value="" />
    <div class="container">
        <div class="content">
            <div class="row">
                <div class="col-md-12">
                    <h3 id="divTitulo" class="page-header">
                        Alterar Status de Cartão</h3>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel-body">
            <div class="row row-margin">
                <div class="panel panel-default">
                    <div class="panel-heading panel-font">
                        Dados do Titular do Cartão
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
                        <div class="row" id="divCadastroPF" runat="server">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label2" runat="server" Text="Data de Nascimento:" CssClass="control-label"></asp:Label>
                                    <asp:Label ID="lblDataNascimento" runat="server" CssClass="control-label-box-default"> </asp:Label>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label3" runat="server" Text="Nome da Mãe:" CssClass="control-label"></asp:Label>
                                    <asp:Label ID="lblNomeMae" runat="server" CssClass="control-label-box-default"> </asp:Label>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-8">
                                <div class="form-group">
                                    <asp:Label ID="Label5" runat="server" Text="Endereço:" CssClass="control-label"></asp:Label>
                                    <asp:Label ID="lblEndereco" runat="server" CssClass="control-label-box-default"> </asp:Label>
                                </div>
                            </div>
                        </div>
                        <hr />
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label1" runat="server" Text="Cartão:" CssClass="control-label"></asp:Label>
                                    <br />
                                    <div class="btn-group">
                                        <button type="button" style="width:200px; text-align: left" id="ddlCartao" class="btn btn-default" >
                                            <i class="fa fa-credit-card-alt fa-fw"></i>  Selecione   </button>
                                        <button id="ddlCartaoToggle" type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown"
                                            aria-haspopup="true" aria-expanded="false">
                                            <span class="caret"></span>
                                        </button>
                                        <ul id="lstCartao" class="dropdown-menu ul-primary-level">
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row display-none" id="divDadosCartao">
                            
                            <div class="col-md-3" id="divLimiteProduto">
                                <div class="form-group">
                                    <asp:Label ID="Label4" runat="server" Text="Limite Produto:" CssClass="control-label"></asp:Label>
                                    <asp:Label ID="lblLimiteProduto" runat="server" Width="200" CssClass="control-label-box-default"> </asp:Label>
                                </div>
                            </div>
                            
                            <div class="col-md-3">
                                <div class="form-group">
                                    <asp:Label ID="Label7" runat="server" Text="Dia do Vencimento / Faturamento:" CssClass="control-label"></asp:Label><br/>
                                    <div class="input-group">
                                    <asp:Label ID="lblVencimento" runat="server" Width="60" CssClass="control-label-box-default input-inline" > </asp:Label> <span style="vertical-align:baseline" > / </span>
                                    <asp:Label ID="lblFaturamento" runat="server" Width="60" CssClass="control-label-box-default input-inline"> </asp:Label>
                                    </div>
                                </div>
                            </div>

                            <div class="col-md-3">
                                <div class="form-group">
                                    <asp:Label ID="Label6" runat="server" Text="Status do Cartão:" CssClass="control-label"></asp:Label>
                                    <asp:Label ID="lblStatusCartao" runat="server" Width="200" CssClass="control-label-box-default"> </asp:Label>
                                </div>
                            </div>

                            <div class="col-md-3" id="divMotivoCartao">
                                <div class="form-group">
                                    <asp:Label ID="Label8" runat="server" Text="Motivo:" CssClass="control-label"></asp:Label>
                                    <asp:Label ID="lblMotivoCartao" runat="server" Width="220" CssClass="control-label-box-default"> </asp:Label>
                                </div>
                            </div>

                        </div>

                        <hr />

                        <div class="row display-none" id="divDadosVia2">
                            <div class="panel-body">
                                <div class="row">
                                    <div class="col-md-4">
                                        <div class="form-group">
                                            <asp:Label ID="lblNomeCartao" runat="server" Text="Nome do Cliente no Cartão:" CssClass="control-label"></asp:Label>
                                            <asp:TextBox ID="txtNomeCartao" runat="server" MaxLength="25" placeholder="Nome do cliente no cartão"
                                                data-required="true" CssClass="form-control input-uppercase"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                                <br />
                                <div class="row">
                                    <div class="col-md-8">
                                        <div class="btnMotivo btn-group" data-toggle="buttons">
                                            <label id="btnMotivoEmbossing" class="btn btn-default" style="width: 130px">
                                                <span class="glyphicon glyphicon-lock"></span>
                                                <input type="radio" id="optEmbossing" name="optMotivo" value="0" />
                                                Embossing
                                            </label>
                                            <label id="btnMotivoPerda" class="btn btn-default" style="width: 130px">
                                                <span class="glyphicon glyphicon-remove"></span>
                                                <input type="radio" id="optPerda" name="optMotivo" value="0" />
                                                Perda
                                            </label>
                                            <label id="btnMotivoRoubo" class="btn btn-default" style="width: 130px">
                                                <span class="glyphicon glyphicon-remove"></span>
                                                <input type="radio" id="optRoubo" name="optMotivo" value="0"/>
                                                Roubo
                                            </label>
                                            <label id="btnMotivoDefeito" class="btn btn-default" style="width: 130px">
                                                <span class="glyphicon glyphicon-lock"></span>
                                                <input type="radio" id="optDefeito" name="optMotivo" value="0" />
                                                Defeito
                                            </label>
                                            <label id="btnMotivoExtravio" class="btn btn-default" style="width: 130px">
                                                <span class="glyphicon glyphicon-lock"></span>
                                                <input type="radio" id="optExtravio" name="optMotivo" value="0" />
                                                Extravio
                                            </label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="display-none" id="divDadosStatus">
                            <div class="row">
                                <div class="col-md-8">
                                    <%--<div class="form-group">
                                        <asp:Label ID="Label41" runat="server" Text="Status do Cartão:" CssClass="control-label"></asp:Label>
                                        <asp:DropDownList ID="ddlStatusCartao" runat="server" CausesValidation="True" data-required="true"
                                            CssClass="form-control" Width="200px">
                                            <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                        </asp:DropDownList>
                                    </div>--%>
                                    <div class="btnStatus btn-group" data-toggle="buttons">
                                        <label id="btnStatusAtivar" class="btn btn-default" style="width: 200px">
                                            <span class="glyphicon glyphicon-ok"></span>
                                            <input type="radio" id="optAtivar" name="optMotivoStatus" value="1" />
                                            Desbloquear Cartão
                                        </label>
                                        <label id="btnStatusBloquear" class="btn btn-default" style="width: 200px">
                                            <span class="glyphicon glyphicon-lock"></span>
                                            <input type="radio" id="optBloquear" name="optMotivoStatus" value="2" />
                                            Bloquear Cartão
                                        </label>
                                        <label id="btnStatusCancelar" class="btn btn-default" style="width: 200px">
                                            <span class="glyphicon glyphicon-remove"></span>
                                            <input type="radio" id="optCancelar" name="optMotivoStatus" value="3"/>
                                            Cancelar Cartão
                                        </label>
                                        <%--
                                        <label id="btnStatusBloqueadoExtravio" class="btn btn-default" style="width: 200px">
                                            <span class="glyphicon glyphicon-lock"></span>
                                            <input type="radio" id="optBloqueadoExtravio" name="optMotivoStatus" value="2"/>
                                            Cartão Extraviado
                                        </label>
                                        --%>
                                    </div>

                                </div>
                            </div>
                            <br />
                            <div class="row">
                                <div class="col-md-4 display-none" id="divMotivo" runat="server">
                                    <div class="form-group">
                                        <asp:Label ID="Label42" runat="server" Text="Motivo:" CssClass="control-label"></asp:Label>
                                        <asp:DropDownList ID="ddlMotivoStatusCartao" runat="server" CausesValidation="True" data-required="true"
                                            CssClass="form-control" Width="200px">
                                            <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                        </asp:DropDownList>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div id="divConfirmarVia2" class="row align-center display-none">
                <asp:LinkButton ID="btnConfirmarVia2" CssClass="btn btn-primary" disabled runat="server" OnClientClick="javascript:return validaFormulario();"
                    OnClick="btnConfirmar_Click" >Solicitar Segunda Via <i class="fa fa-check"></i></asp:LinkButton>
                <%--   
                <button id="btnNovaSenha" class="btn btn-primary" data-toggle="modal" data-target="#modalNovaSenha" disabled>
                    Solicitar Nova Senha <i class="fa fa-check"></i>
                </button>
                --%>
            </div>
            <div id="divConfirmarStatus" class="row align-center display-none">
                <asp:LinkButton ID="btnConfirmarStatus" CssClass="btn btn-primary" disabled runat="server" OnClientClick="javascript:return validaFormulario();"
                    OnClick="btnConfirmar_Click" >Confirmar <i class="fa fa-check"></i></asp:LinkButton>
                
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

    <div class="modal fade" id="modalNovaSenha" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <h4 class="modal-title" id="myModalLabel">Solicitar Nova Senha</h4>
                </div>
                <div class="modal-body">
                    Confirmando esta operação você estará mudando a senha de autorização deste cartão.<br />
                    Logo, o mesmo será impedido de efetuar qualquer operação utlizando a senha antiga.<br /><br />
                    Deseja realmente confirmar esta operação?
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Cancelar</button>
                    <%--<button type="button" class="btn btn-primary">Confirmar</button>--%>
                    <asp:LinkButton ID="btnConfirmarNovaSenha" CssClass="btn btn-primary" runat="server" OnClientClick="javascript:return validaNovaSenha();"
                    OnClick="btnConfirmar_Click" >Confirmar <i class="fa fa-check"></i></asp:LinkButton>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade alert" id="modalErro" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog alert-danger" style="width: 450px">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">
                        &times;</button>
                    <h4 class="modal-title">
                        Cliente Cartão</h4>
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
    if (operacao == "Erro") {
        $("#modalErro").modal("show");
    }
    $('[id$=hdnOperacao]').val('');

    if (request("via2") != "" && request("via2") == "true")
        OperacaoCartao = "Alteracao2Via";
    else
        OperacaoCartao = "AlteracaoStatus";

    UsuarioTitular = $.parseJSON($('[id$=hdnTitular]').val());
    MotivoSegundaVia = $.parseJSON($('[id$=hdnMotivo]').val());
    
    var ul_primary = $('#lstCartao');

    var cartaoTitular = UsuarioTitular.Conta.ContaProduto.forEach(function (itemTitular) {
        var li = $('<li/>').appendTo(ul_primary);
        var a = $('<a/>').attr('href', '#')
                         .attr('data-cod_cartao', itemTitular.Cartao.CodCartao)
                         .attr('data-toggle', 'tooltip')
                         .attr('data-placement', 'right')
                         .attr('title', 'Titular: ' + itemTitular.Cartao.NomeBandeira + ' - ' + itemTitular.Cartao.NomeProduto)
                         .addClass('cart').text(itemTitular.Cartao.NumeroCartao)
                         .appendTo(li);
        if (itemTitular.Cartao.StatusCartao == "Cancelado") {
            a.addClass('color-red')
        }

        if (itemTitular.Cartao.Adicional != null) {
            var ul_second = $('<ul/>').addClass('ul-second-level').appendTo(li);
            var cartaoAdicional = itemTitular.Cartao.Adicional.filter(function (itemAdicional) {
                var li2 = $('<li/>').appendTo(ul_second);
                var a2 = $('<a/>').attr('href', '#')
                                  .attr('data-cod_cartao', itemAdicional.CartaoAdicional.CodCartao)
                                  .attr('data-toggle', 'tooltip')
                                  .attr('data-placement', 'right')
                                  .attr('title', 'Adicional: ' + itemAdicional.CartaoAdicional.NomeBandeira + ' - ' + itemAdicional.CartaoAdicional.NomeProduto)
                                  .addClass('cart').text(' ' + itemAdicional.CartaoAdicional.NumeroCartao)
                                  .appendTo(li2);
                if (itemAdicional.CartaoAdicional.StatusCartao == "Cancelado") {
                    a2.addClass('color-red')
                }
            });
        }

    });

    if (OperacaoCartao == "Alteracao2Via") {

        $("#optEmbossing").val(obtemValor('Embossing', MotivoSegundaVia));
        $("#optPerda").val(obtemValor('Perda', MotivoSegundaVia));
        $("#optRoubo").val(obtemValor('Roubo', MotivoSegundaVia));
        $("#optDefeito").val(obtemValor('Defeito', MotivoSegundaVia));
        $("#optExtravio").val(obtemValor('Extravio', MotivoSegundaVia));

    }
    
    function obtemValor(nome, lista) {
        var valor = "";
        lista.filter(function (motivo) {
            if (motivo.Nome.toUpperCase() == nome.toUpperCase()) {
                valor = motivo.Valor;
                return;
            }
        });

        return valor;
    }

</script>

</html>

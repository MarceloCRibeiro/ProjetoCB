<%@ Page Language="C#" AutoEventWireup="true" EnableEventValidation="false" CodeFile="Titular.aspx.cs"
    Inherits="Titular" %>
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
    
    <link rel="stylesheet" type="text/css" href="../../css/cssTitular.css" />

    <script language="javascript" type="text/javascript" src="../../js/jquery-3.1.1.min.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/jquery.mask.min.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/jquery.maskMoney.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/bootstrap.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/metisMenu/metisMenu.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/sb-admin-2.js"></script>
    <script language="javascript" type="text/javascript" src="../../js/default.js"></script>

    <script language="javascript" type="text/javascript">
        var StepFormulario = 1;
        var ArrayVencimentoFatura = {};
        var ArrayRendaProduto = {};
        var ArrayRendaGrupoTarifaDefault = {};
        var ArrayBandeiraVencimento = {};
        var DivConta = false;
        var DivLimite = false;

        var ResponsavelItem = null;
        var EnderecoItem = null;
        var EmailItem = null;
        var TelefoneItem = null;
        
        var Usuario = "";
        var UsuarioTitular = "";
        var UsuarioOperacao = "";

        $(document).ready(function () {

            carregaListaBandeira();
            carregaTipoResponsavel();
            carregaEstadoCivil();
            carregaEscolaridade();
            carregaProfissao();
            carregaTipoEndereco();
            carregaListaVencimento();
            carregaVencimentoEmissor();
            carregaTipoOperacaoCartao();
            //carregaStatusCartao();
            //carregaTipoBloqueioCartao();
            carregaListaBanco();
            carregaTipoEmpresa();
            carregaTipoTelefone();
            
            var popOverSettings = {
                placement: 'bottom',
                container: 'body',
                html: true,
                selector: '[rel="popover"]', //Sepcify the selector here
                content: function () {
                    return $('#popover-content').html();
                }
            }

            $('#tab-step1, #tab-step2, #tab-step3, #tab-step4').click(function () {

                $('.tab-dados').attr('class', 'tab-dados')
                $(this).parent().attr('class', 'tab-dados active')

                var step = this.id

                if (step == 'tab-step1')
                    step1();
                else if (step == 'tab-step2')
                    step2();
                else if (step == 'tab-step3')
                    step3();
                //else if (step == 'tab-step4')
                //    step4();

            });

            $('body').popover(popOverSettings);

            $('#txtIdentidade').mask('99999999999999999999');

            $('#btn-step1, #btn-step2, #btn-step3, #btn-step4').click(function () {

                var step = $(this).text().trim();

                $("#divTimeLine").fadeOut(function () {
                    if (step == '1')
                        step1();
                    else if (step == '2')
                        step2();
                    else if (step == '3')
                        step3();
                    else if (step == '4')
                        step4();

                });

                $('#divTimeLine').fadeIn('slow');
                $(this).blur();

            })

            $('#btnIncluirEndereco').click(function () {
                var valida = validaDadosEndereco();
                if (valida) {
                    if (EnderecoItem != null)
                        alteraListaEnderecos();
                    else
                        insereListaEnderecos();

                    $('#btnCancelarEndereco').trigger("click");

                }

                $('#btnIncluirEndereco').blur();
                
            })

            $('#btnCancelarEndereco').click(function () {
                EnderecoItem = null;

                $('#divComercial').slideUp();
                $('#btnCancelarEndereco').hide();

                $('#btnIncluirEndereco').html('<i class="fa fa-plus"></i> Incluir Endereço');

                $('#txtCep').val('');
                $('#ddlTipoEndereco').val('');
                $('#txtNomeEmpresa').val('');
                $('#ddlTipoEmpresa').val('');
                $('#ddlRegistradoCarteira').val('');
                $('#txtEndereco').val('');
                $('#txtNumero').val('');
                $('#txtComplemento').val('');
                $('#txtBairro').val('');
                $('#txtCidade').val('');
                $('#ddlEstado').val('');
                $('#chkCobranca').prop("checked", false)

                exibeError($('#txtCep'), false);
                exibeError($('#ddlTipoEndereco'), false);
                exibeError($('#txtNomeEmpresa'), false);
                exibeError($('#ddlTipoEmpresa'), false);
                exibeError($('#ddlRegistradoCarteira'), false);
                exibeError($('#txtEndereco'), false);
                exibeError($('#txtNumero'), false);
                exibeError($('#txtComplemento'), false);
                exibeError($('#txtBairro'), false);
                exibeError($('#txtCidade'), false);
                exibeError($('#ddlEstado'), false);

                $("#table-enderecos tr").removeClass();

            })

            $('#btnIncluirEmail').click(function () {
                var valida = validaDadosEmail();
                if (valida) {
                    if (EmailItem != null)
                        alteraListaEmails();
                    else
                        insereListaEmails();

                    $('#btnCancelarEmail').trigger("click");
                }
                
                $('#btnIncluirEmail').blur();
                
            })

            $('#btnCancelarEmail').click(function () {
                EmailItem = null;

                $('#btnCancelarEmail').hide();

                $('#btnIncluirEmail').html('<i class="fa fa-plus"></i> Incluir Email');

                $('#txtEmail').val('');
                $('#chkEPrincipal').prop("checked", false);

                exibeError($('#txtEmail'), false);
                
                $("#table-emails tr").removeClass();

            })

            $('#btnIncluirTelefone').click(function () {
                var valida = validaDadosTelefone();
                if (valida) {
                    if (TelefoneItem != null)
                        alteraListaTelefones();
                    else
                        insereListaTelefones();

                    $('#btnCancelarTelefone').trigger("click");
                }
                    
                return false;
            })

            $('#btnCancelarTelefone').click(function () {
                TelefoneItem = null;

                $('#btnCancelarTelefone').hide();

                $('#btnIncluirTelefone').html('<i class="fa fa-plus"></i> Incluir Telefone');

                $('#txtTelefone').val('');
                $('#ddlFinTelefone').val('');
                $('#txtObservacao').val('');
                
                exibeError($('#txtTelefone'), false);
                exibeError($('#ddlFinTelefone'), false);
                exibeError($('#txtObservacao'), false);

                $("#table-telefones tr").removeClass();

            })

            $('#btnIncluirResponsavel').click(function () {
                var valida = validaDadosResponsavel();
                if (valida) {
                    if (ResponsavelItem != null)
                        alteraListaResponsaveis();
                    else
                        insereListaResponsaveis();

                    $('#btnCancelarResponsavel').trigger("click");

                }

                $('#btnIncluirResponsavel').blur();
                return false;

            })

            $('#btnCancelarResponsavel').click(function () {
                ResponsavelItem = null;

                $('#btnCancelarResponsavel').hide();

                $('#btnIncluirResponsavel').html('<i class="fa fa-plus"></i> Incluir Responsável');

                $('#ddlTipoResponsavel').val('');
                $('#txtCpfResponsavel').val('');
                $('#txtNomeResponsavel').val('');
                exibeError($('#ddlTipoResponsavel'), false);
                exibeError($('#txtCpfResponsavel'), false);
                exibeError($('#txtNomeResponsavel'), false);

                $("#table-responsaveis tr").removeClass();

            })

            $('#btnCep').click(function () {
                if ($('#txtCep').val() == '') return;

                if ($('#txtCep').val().trim().length != 9) {
                    exibePopover($('#txtCep'), "CEP inválido");

                    if ($('#txtCep').attr('data-required') !== undefined) {
                        if ($('#txtCep').attr('data-required') == "" || $('#txtCep').attr('data-required').toLowerCase() != "false") {
                            exibeError($('#txtCep'), true);
                        }
                    }
                }
                //webservice viacep.com.br/
                $.getJSON("//viacep.com.br/ws/" + $('#txtCep').val() + "/json/?callback=?", function (dados) {

                    if (!dados.erro) {
                        $('#txtEndereco').val(dados.logradouro);
                        $('#txtBairro').val(dados.bairro);
                        $('#txtCidade').val(dados.localidade);
                        $('#ddlEstado').val(dados.uf);
                    }
                });

                $('#ddlTipoEndereco').focus();

            })

            $('#btnAnterior').click(function () {
                if (StepFormulario == 2) {
                    step1();
                }
                else if (StepFormulario == 3) {
                    step2();
                }
                else if (StepFormulario == 4) {
                    step3();
                }
                else if (StepFormulario == 5) {
                    step4();
                }

                $("#btnAnterior").blur();

            })

            $("#txtRendaMensal").keyup(function () {

                $('#divLimitesProduto').slideUp();

                $('#ddlGrupoTarifa').empty();
                $('#ddlGrupoTarifa').popover('destroy');
                $('#txtVencimentoGrupoTarifario').val('');

                exibeError($('#ddlProduto'), false);
                $('#ddlProduto').val('');

            });

            $("#txtFaixaIniBloqExt, #txtFaixaFimBloqExt").keyup(function () {
                exibeError($('#txtFaixaIniBloqExt'), false);
                exibeError($('#txtFaixaFimBloqExt'), false);
            });

            $("#ddlEstadoCivil").change(function () {
                exibeError($('#txtConjuge'), false);
            });

            $("#ddlBloqueadoExterior").change(function () {
                var valor = $('#ddlBloqueadoExterior option:selected').val();

                if (valor == "0") {
                    $('#divFaixaIniBloqExt').fadeIn('slow');
                    $('#divFaixaFimBloqExt').fadeIn('slow');
                    $("#txtFaixaIniBloqExt").focus();
                }
                else {
                    $('#divFaixaIniBloqExt').fadeOut('slow');
                    $('#divFaixaFimBloqExt').fadeOut('slow');
                    $('#txtFaixaIniBloqExt').val('');
                    $('#txtFaixaFimBloqExt').val('');

                }

                exibeError($('#ddlBloqueadoExterior'), false);

            });

            $("#ddlTipoOperacaoCartao").change(function () {
                var tipo = $('#ddlTipoOperacaoCartao option:selected').text();
                var deb = $('#ddlDebAutomatico option:selected').text();

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
                    var tipo = $('#ddlTipoOperacaoCartao option:selected').text().toLowerCase();

                    if (tipo == "crédito" || tipo == "selecione") {
                        $('#divConta').slideUp();
                        DivConta = false;
                    }
                }

            });

            $("#ddlTipoEndereco").change(function () {
                var valor = $('#ddlTipoEndereco option:selected').text().toLowerCase();

                if (valor == "comercial" && Usuario == "PF") {
                    $('#divComercial').slideDown();
                    $('#txtNomeEmpresa').val('');
                    $('#ddlTipoEmpresa').val('');
                    $('#ddlRegistradoCarteira').val('');

                    $("#txtNomeEmpresa").focus();
                }
                else {
                    $('#divComercial').slideUp();

                    if ($('#txtEndereco').val() != "")
                        $('#txtNumero').focus();
                    else
                        $("#txtEndereco").focus();
                }

            });

            $("#txtNomeCartao").focusout(function (event) {
                $(this).val(removerAcentos($(this).val()));
            });

            $('#ddlBandeira').change(function () {
                carregaListaProduto();
            });

            $('#ddlProduto').change(function () {

                var tipoOperacao = $('#ddlTipoOperacaoCartao option:selected').text();
                if (isNullOrEmpty($('#ddlProduto').val()) || tipoOperacao == "Débito") {
                    $('#divLimitesProduto').slideUp();
                    DivLimite = false;

                    $('#ddlGrupoTarifa').empty();
                    $('#ddlGrupoTarifa').popover('destroy');
                    $('#txtVencimentoGrupoTarifario').val('');

                    $('#divVencimentoGrupoTarifario').fadeOut("slow");
                    $('#txtVencimentoGrupoTarifario').val('');

                    return false;
                }

                var rendaProduto = ArrayRendaProduto[$('#ddlProduto').val()];
                var renda = retornaFloat($('#txtRendaMensal').val());

                if (renda < rendaProduto) {

                    if (Usuario == "PJ")
                        exibeCampoObrigatorio($('#ddlProduto'), "O patrimônio liquido é insuficiente para o Produto <b>" + $("#ddlProduto option:selected").text() + "</b>");
                    else
                        exibeCampoObrigatorio($('#ddlProduto'), "A renda mensal é insuficiente para o Produto <b>" + $("#ddlProduto option:selected").text() + "</b>");

                    $('#divLimitesProduto').slideUp();
                    DivLimite = false;

                    $('#ddlGrupoTarifa').empty();
                    $('#ddlGrupoTarifa').popover('destroy');
                    $('#txtVencimentoGrupoTarifario').val('');

                    $('#divVencimentoGrupoTarifario').fadeOut("slow");
                    $('#txtVencimentoGrupoTarifario').val('');

                    $('#ddlProduto').focus();
                    return;
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

            $('#txtLimiteConta').keyup(function (e) {
                exibeError($(this), false);

                if ($('#txtLimiteProduto').val().trim() != "") {
                    exibeError($('#txtLimiteProduto'), false);
                }

            });

            $('#txtLimiteProduto').keyup(function (e) {
                exibeError($(this), false);

                if ($('#txtLimiteConta').val().trim() != "") {
                    exibeError($('#txtLimiteConta'), false);
                }

            });

            $('#txtCpf').focusout(function (e) {
                if ($('#txtCpf').val().trim() != "") {
                    if (UsuarioOperacao == "Inclusao") {
                        if (!validaCliente($('#txtCpf'))) {
                            exibeCampoObrigatorio($('#txtCpf'), "Cliente já cadastrado");
                        }
                    }
                }
            });

            $('#txtLimiteProduto').focusout(function (e) {

                if ($('#txtLimiteConta').val().trim() != "" & $('#txtLimiteProduto').val().trim() != "") {
                    //var valorConta = parseFloat($('#txtLimiteConta').val().replace('.', '').replace(',', '.'));
                    //var valorProduto = parseFloat($('#txtLimiteProduto').val().replace('.', '').replace(',', '.'));

                    var valorConta = retornaFloat($('#txtLimiteConta').val());
                    var valorProduto = retornaFloat($('#txtLimiteProduto').val());

                    if (valorProduto > valorConta) {
                        setTimeout(function () { exibeError($('#txtLimiteProduto'), true); exibePopover($('#txtLimiteProduto'), "O limite do produto não pode ser maior que o limite da conta"); exibeError($('#txtLimiteConta'), true); }, 100);

                    }
                }

            });

            $('#txtCep').focusout(function (e) {
                if ($(this).val() == '') return;

                if ($(this).val().trim().length != 9) {
                    exibePopover($(this), "CEP inválido");

                    if ($(this).attr('data-required') !== undefined) {
                        if ($(this).attr('data-required') == "" || $(this).attr('data-required').toLowerCase() != "false") {
                            exibeError($(this), true);
                        }
                    }
                }
                else {
                    $("#btnCep").trigger("click");
                }

            });

            $("#ddlDiaVencimento").change(function () {

                var faturamento = ArrayVencimentoFatura[$(this).val()];

                if ($('#ddlDiaVencimento').val() != '') {
                    //$("#txtDiaFaturamento").val($('#ddlDiaVencimento option:selected').text());
                    //$("#txtDiaFaturamento").val(faturamento);
                    $("#lblDiaFaturamento").text(faturamento);
                }
                else {
                    $("#lblDiaFaturamento").text('');
                }

            });

            //$("#txtCpf").focus();

            //$("#hdnListaEnderecos").val('');
            //$("#hdnListaTelefones").val('');
            //$("#hdnListaEmails").val('');
            //$("#hdnListaLimites").val('');
            //$("#hdnTipoValorLimite").val('');

            $("#ddlProduto").attr("disabled", "disabled");

        });


        function carregaListaLimiteProduto(codConta, codProduto, codAdicional) {
            $('#divLimitesProduto').slideUp();
            DivLimite = false;

            $('#ddlGrupoTarifa').empty();
            $('#ddlGrupoTarifa').popover('destroy');
            $('#txtVencimentoGrupoTarifario').val('');

            $('#divVencimentoGrupoTarifario').fadeOut("slow");
            $('#txtVencimentoGrupoTarifario').val('');

            $("#table-limites tbody tr").remove();
            
            if ($('#ddlProduto').val() == '') {
                return;
            }

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
                url: 'Titular.aspx/ObterDadosLimiteProduto',
                data: param,
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {
                        DivLimite = true;

                        $.each(jsonResult.Resultado, function (index, item) {

                            var html = '' +
                            "<tr>" +
                                "<th style='width: 200px; text-align:right; padding-top:15px; font-weight:normal'>" +
                                "<span> nomeLimite: </span>" +
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

        /// metodo não utilizado
        function calculaTotais() {

            var totalLimitesProduto = 0.0;
            var limites = $('[id*=valorLimite]');
            for (var i = 0; i < limites.length; i++) {
                var item = $(limites[i]);
                if (item.val().trim() != "") {
                    // valor absoluto(R$)
                    //totalLimitesProduto += parseFloat(item.val().replace('.', '').replace(',', '.'));
                    // valor percentual(%)
                    totalLimitesProduto += retornaFloat(item.val());
                }
            }

            var totalProduto = 0.0;
            var totalLimite = 0.0;
            if ($('#txtLimiteProduto').val().trim() != "") {
                //totalProduto = parseFloat($('#txtLimiteProduto').val().replace('.', '').replace(',', '.'));
                totalProduto = retornaFloat($('#txtLimiteProduto').val());
            }

            var totalLimite = 0.0;

            // valor absoluto(R$)
            //totalLimite = totalProduto - totalLimitesProduto;
            //$('#infoTotalLimite').text('R$ ' + retornaValor(totalLimitesProduto));
            //$('#infoTotalDisponivel').text('R$ ' + retornaValor(totalLimite));

            // valor percentual(%)
            //totalLimite = 100 - totalLimitesProduto;
            //$('#infoTotalLimite').text(totalLimitesProduto + '%');
            //$('#infoTotalDisponivel').text('R$ ' + totalLimite);
            //
            //if (totalLimite < 0) {
            //    $('#infoTotalDisponivel').attr('class', 'color-red');
            //}
            //else {
            //    $('#infoTotalDisponivel').attr('class', 'color-blue');
            //}

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
                url: 'Titular.aspx/ObterDadosGrupoTarifa',
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

        function carregaVencimentoEmissor() {

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Titular.aspx/ObterVencimentoEmissor',
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado != null) {

                        var dias = jsonResult.Resultado.DiasRenovacaCartao;
                        var vencimento = new Date();
                        vencimento.setDate(vencimento.getDate() + dias);
                        $('#lblDataVencimentoEmissor').text(toFormatString(vencimento));
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
                        exibeError($('#lblDataVencimentoEmissor'), true);
                    }
                },
                error: function (response) {
                    //$("#modalErro").modal("show");
                    exibeError($('#lblDataVencimentoEmissor'), true);
                    window.location.href = "../../Erro.aspx";
                }
            });

        }

        function carregaTipoOperacaoCartao() {

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Titular.aspx/ObterListaTipoCartao',
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        //$('#ddlTipoOperacaoCartao').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));
                        $.each(jsonResult.Resultado, function (index, item) {
                            $('#ddlTipoOperacaoCartao').append($('<option>', { value: item.Valor, text: item.Nome }, '</option>'));

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
                        exibeError($('#ddlTipoOperacaoCartao'), true);
                    }
                },
                error: function (response) {
                    //$("#modalErro").modal("show");
                    exibeError($('#ddlTipoOperacaoCartao'), true);
                    window.location.href = "../../SessaoFinalizada.aspx";
                }
            });

        }

        function carregaStatusCartao() {

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Titular.aspx/ObterListaStatusCartao',
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        //$('#ddlStatusCartao').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));
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
                url: 'Titular.aspx/ObterListaTipoBloqueioCartao',
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        //$('#ddlTipoBloqueio').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));
                        $.each(jsonResult.Resultado, function (index, item) {
                            $('#ddlTipoBloqueio').append($('<option>', { value: item.Valor, text: item.Nome }, '</option>'));

                        })

                        $('#divTipoBloqueio').fadeIn("slow");
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

        function carregaEstadoCivil() {

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Titular.aspx/ObterListaEstadoCivil',
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        //$('#ddlEstadoCivil').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));
                        $.each(jsonResult.Resultado, function (index, item) {
                            $('#ddlEstadoCivil').append($('<option>', { value: item.Valor, text: item.Nome }, '</option>'));

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
                        exibeError($('#ddlEstadoCivil'), true);
                    }

                },
                error: function (response) {
                    exibeError($('#ddlEstadoCivil'), true);
                    window.location.href = "../../Erro.aspx";
                }
            });

        }

        function carregaTipoResponsavel() {

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Titular.aspx/ObterListaTipoResponsavel',
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        //$('#ddlTipoResponsavel').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));
                        $.each(jsonResult.Resultado, function (index, item) {
                            $('#ddlTipoResponsavel').append($('<option>', { value: item.Valor, text: item.Nome }, '</option>'));

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
                        exibeError($('#ddlTipoResponsavel'), true);
                    }

                },
                error: function (response) {
                    exibeError($('#ddlTipoResponsavel'), true);
                    window.location.href = "../../Erro.aspx";
                }
            });

        }

        function carregaEscolaridade() {

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Titular.aspx/ObterListaEscolaridade',
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

        function carregaProfissao() {

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Titular.aspx/ObterListaProfissao',
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        //$('#ddlProfissao').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));
                        $.each(jsonResult.Resultado, function (index, item) {
                            $('#ddlProfissao').append($('<option>', { value: item.Valor, text: item.Nome }, '</option>'));

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
                        exibeError($('#ddlProfissao'), true);
                    }

                },
                error: function (response) {
                    //$("#modalErro").modal("show");
                    exibeError($('#ddlProfissao'), true);
                    window.location.href = "../../Erro.aspx";
                }
            });

        }

        function carregaTipoEndereco() {

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Titular.aspx/ObterListaTipoEndereco',
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        //$('#ddlTipoEndereco').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));
                        $.each(jsonResult.Resultado, function (index, item) {
                            $('#ddlTipoEndereco').append($('<option>', { value: item.Valor, text: item.Nome }, '</option>'));
                        })

                        if (Usuario == "PJ")
                            $('#ddlTipoEndereco').val('2'); // Comercial
                        else
                            $('#ddlTipoEndereco').val('1'); // Residencial

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
                        exibeError($('#ddlTipoEndereco'), true);
                    }

                },
                error: function (response) {
                    //$("#modalErro").modal("show");
                    exibeError($('#ddlTipoEndereco'), true);
                    window.location.href = "../../Erro.aspx";
                }
            });

        }

        function carregaTipoEmpresa() {

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Titular.aspx/ObterListaTipoEmpresa',
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        //$('#ddlTipoEmpresa').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));
                        $.each(jsonResult.Resultado, function (index, item) {
                            $('#ddlTipoEmpresa').append($('<option>', { value: item.Valor, text: item.Nome }, '</option>'));

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
                        exibeError($('#ddlTipoEmpresa'), true);
                    }

                },
                error: function (response) {
                    //$("#modalErro").modal("show");
                    exibeError($('#ddlTipoEmpresa'), true);
                    window.location.href = "../../Erro.aspx";
                }
            });

        }

        function carregaTipoTelefone() {

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Titular.aspx/ObterListaTipoTelefone',
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        //$('#ddlFinTelefone').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));
                        $.each(jsonResult.Resultado, function (index, item) {
                            $('#ddlFinTelefone').append($('<option>', { value: item.Valor, text: item.Nome }, '</option>'));
                        })

                        if (Usuario == "PJ")
                            $('#ddlFinTelefone').val('2');
                        else
                            $('#ddlFinTelefone').val('1');

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
                        exibeError($('#ddlFinTelefone'), true);
                    }
                },
                error: function (response) {
                    //$("#modalErro").modal("show");
                    exibeError($('#ddlFinTelefone'), true);
                    window.location.href = "../../Erro.aspx";
                }
            });

        }

        function carregaFinalidadeTelefone() {

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Titular.aspx/ObterListaFinalidadeTelefone',
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        //$('#ddlFinTelefone').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));
                        $.each(jsonResult.Resultado, function (index, item) {
                            $('#ddlFinTelefone').append($('<option>', { value: item.Valor, text: item.Nome }, '</option>'));
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
                        exibeError($('#ddlFinTelefone'), true);
                    }

                },
                error: function (response) {
                    //$("#modalErro").modal("show");
                    exibeError($('#ddlFinTelefone'), true);
                    window.location.href = "../../Erro.aspx";
                }
            });

        }

        function validaCliente(objCpf_Cnpj, asynctask) {
            var ret = true;

            var cliente = objCpf_Cnpj.val().trim();

            cliente = cliente.replace('.', '').replace('.', '');
            cliente = cliente.replace('-', '');
            cliente = cliente.replace('/', '');

            if (asynctask === undefined)
                asynctask = true;

            var param = JSON.stringify({
                cpf_cnpj: cliente
            });

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Titular.aspx/TitularExiste',
                data: param,
                dataType: "json",
                async: asynctask,
                success: function (response) {
                    var existe = response.d;

                    if (existe) {
                        ret = false;

                        if (asynctask) {
                            exibeCampoObrigatorio(objCpf_Cnpj, "Cliente já cadastrado");
                        }
                    }

                },
                error: function (response) {
                    exibeError(objCpf_Cnpj, true);
                    ret = false
                }
            });

            return ret;

        }

        function validaEmailCliente(email, asynctask) {
            var ret = true;

            if (asynctask === undefined)
                asynctask = true;

            var param = JSON.stringify({
                email: email
            });

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Titular.aspx/ContatoExiste',
                data: param,
                dataType: "json",
                async: false,
                success: function (response) {
                    var existe = response.d;

                    if (existe) {
                        ret = false;

                        if (asynctask) {
                            exibeCampoObrigatorio($('#txtEmail'), "Email já cadastrado");
                        }
                    }
                },
                error: function (response) {
                    //exibeError($('#txtEmail'), true);
                    ret = true;
                }
            });

            return ret;

        }

        function carregaListaVencimento() {

            ArrayVencimentoFatura = {};

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Titular.aspx/ObterDadosVencimentoFatura',
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

        function carregaListaBandeira() {

            ArrayBandeiraVencimento = {};

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Titular.aspx/ObterListaBandeira',
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

        function carregaListaBanco() {

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Titular.aspx/ObterListaBanco',
                //data: param,
                dataType: "json",
                async: true,
                success: function (response) {
                    var jsonResult = response.d;

                    if (jsonResult.Resposta && jsonResult.Resultado.length > 0) {

                        //$('#ddlBanco').append($('<option>', { text: 'Selecione', value: '' }, '</option>'));
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
            //$('#txtDataVencimentoBandeira').val(vencimento.toLocaleDateString());
            $('#lblDataVencimentoBandeira').text(vencimento.toLocaleDateString());
            $('#divDataVencimentoBandeira').fadeIn("slow")

            var param = JSON.stringify({
                codBandeira: $('#ddlBandeira option:selected').val()
            });

            $(".loading").fadeIn("slow");

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: 'Titular.aspx/ObterListaProduto',
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
                url: 'Titular.aspx/ObterListaGrupoTarifa',
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

        function validaFormulario() {
            var valida = false;

            try {
                if (UsuarioOperacao == "Inclusao") {

                    if (StepFormulario == 1) {
                        valida = validaDadosCliente();
                        if (valida)
                            step2();
                        return false;
                    }
                    else if (StepFormulario == 2) {
                        valida = validaDadosListaEndereco();
                        if (valida)
                            step3();
                        return false;
                    }
                    else if (StepFormulario == 3) {
                        valida = validaDadosListaContato();
                        if (valida)
                            step4();
                        return false;
                    }
                    else if (StepFormulario == 4) {
                        valida = validaDadosCartao();

                        if (valida) {
                            valida = validaDadosCliente();
                            if (valida) {
                                valida = validaDadosListaEndereco();
                                if (valida) {
                                    valida = validaDadosListaContato();
                                    if (!valida) {
                                        step3();
                                        return false;
                                    }
                                }
                                else {
                                    step2();
                                    return false;
                                }
                            }
                            else {
                                step1();
                                return false;
                            }
                        }
                        else
                            return false;
                    }
                    else
                        return false;

                }
                else {
                    valida = validaDadosCliente();
                    if (valida) {
                        valida = validaDadosListaEndereco();
                        if (valida) {
                            valida = validaDadosListaContato();
                            if (!valida) {
                                //step3();
                                $("#tab-step3").trigger("click");
                                return false;
                            }
                        }
                        else {
                            //step2();
                            $("#tab-step2").trigger("click");
                            return false;
                        }
                    }
                    else {
                        //step1();
                        $("#tab-step1").trigger("click");
                        return false;
                    }
                }

                valida = true;

            }
            catch (err) {
                $("#MensagemErro").text('Erro ao validar os dados do cliente!');
                $("#modalErro").modal("show");
                return false;
            }

            return valida;

            //return valida
            //e.preventDefault();
            //__doPostBack('btnConfirmar_Click', '');

        }

        function validaDadosCliente() {

            if (Usuario == "PJ") {
                if ($('#txtCnpj').val().trim() == "") {
                    step1();
                    exibeCampoObrigatorio($('#txtCnpj'));
                    $('#txtCnpj').focus();
                    return false;
                }

                if (!validaCnpj($('#txtCnpj').val().trim())) {
                    step1();
                    exibeCampoObrigatorio($('#txtCnpj'), "CNPJ inválido");
                    $('#txtCnpj').focus();
                    return false;
                }

                if (UsuarioOperacao == "Inclusao") {
                    if (!validaCliente($('#txtCnpj'), false)) {
                        step1();
                        exibeCampoObrigatorio($('#txtCnpj'), "Cliente já cadastrado");
                        return false;
                    }
                }

                if ($('#txtRazaoSocial').val().trim() == "") {
                    step1();
                    exibeCampoObrigatorio($('#txtRazaoSocial'));
                    $('#txtRazaoSocial').focus();
                    return false;
                }

                if ($('#txtNomeFantasia').val().trim() == "") {
                    step1();
                    exibeCampoObrigatorio($('#txtNomeFantasia'));
                    $('#txtNomeFantasia').focus();
                    return false;
                }

                if ($('#txtDataFundacao').val().trim() != "") {
                    if (!validaData($('#txtDataFundacao').val().trim())) {
                        step1();
                        exibeCampoObrigatorio($('#txtDataFundacao'), "Data inválida");
                        $('#txtDataFundacao').focus();
                        return false;
                    }
                }

                if (!comparaDataAtual($('#txtDataFundacao').val().trim())) {
                    step1();
                    exibeCampoObrigatorio($('#txtDataFundacao'), "Data inválida");
                    $('#txtDataFundacao').focus();
                    return false;
                }

                var listaResp = $('input#hdnListaResponsaveis').val();
                if (listaResp == "") {
                    var valida = validaDadosResponsavel();
                    if (valida) {
                        insereListaResponsaveis();
                        listaResp = $.parseJSON($('input#hdnListaResponsaveis').val());
                    }
                    else {
                        return false;
                    }

                }
                else {
                    listaResp = $.parseJSON(listaResp);
                    var validaListaResponsavel = false
                    for (var i = 0; i < listaResp.length; i++) {
                        if (listaResp[i].Ativo) {
                            validaListaResponsavel = true;
                        }
                    }
                    if (!validaListaResponsavel) {
                        $('#divValidaResponsaveis').slideDown();
                        
                        setTimeout(function () {
                            $('#divValidaResponsaveis').slideUp();
                        }, 5000);

                        return false;
                    }
                }

            }
            else {
                if ($('#txtCpf').val().trim() == "") {
                    step1();
                    exibeCampoObrigatorio($('#txtCpf'));
                    $('#txtCpf').focus();
                    return false;
                }

                if (!validaCpf($('#txtCpf').val().trim())) {
                    step1();
                    exibeCampoObrigatorio($('#txtCpf'), "CPF inválido");
                    $('#txtCpf').focus();
                    return false;
                }

                if (UsuarioOperacao == "Inclusao") {
                    if (!validaCliente($('#txtCpf'), false)) {
                        step1();
                        exibeCampoObrigatorio($('#txtCpf'), "Cliente já cadastrado");
                        return false;
                    }
                }

                if ($('#txtIdentidade').val().trim() == "") {
                    step1();
                    exibeCampoObrigatorio($('#txtIdentidade'));
                    $('#txtIdentidade').focus();
                    return false;
                }

                if ($('#txtOrgaoEmissor').val().trim() == "") {
                    step1();
                    exibeCampoObrigatorio($('#txtOrgaoEmissor'));
                    $('#txtOrgaoEmissor').focus();
                    return false;
                }

                if ($('#ddlUfOrgaoEmissor')[0].selectedIndex < 1) {
                    step1();
                    exibeCampoObrigatorio($('#ddlUfOrgaoEmissor'));
                    $('#ddlUfOrgaoEmissor').focus();
                    return false;
                }

                if ($('#txtNomeUsu').val().trim() == "") {
                    step1();
                    exibeCampoObrigatorio($('#txtNomeUsu'));
                    $('#txtNomeUsu').focus();
                    return false;
                }

                if ($('#txtDtNascimento').val().trim() == "") {
                    step1();
                    exibeCampoObrigatorio($('#txtDtNascimento'));
                    $('#txtDtNascimento').focus();
                    return false;
                }

                if (!comparaDataAtual($('#txtDtNascimento').val().trim())) {
                    step1();
                    exibeCampoObrigatorio($('#txtDtNascimento'), "Data inválida");
                    $('#txtDtNascimento').focus();
                    return false;
                }

                if (!validaData($('#txtDtNascimento').val().trim())) {
                    step1();
                    exibeCampoObrigatorio($('#txtDtNascimento'), "Data inválida");
                    $('#txtDtNascimento').focus();
                    return false;
                }

                if ($('#ddlSexo')[0].selectedIndex < 1) {
                    step1();
                    exibeCampoObrigatorio($('#ddlSexo'));
                    $('#ddlSexo').focus();
                    return false;
                }

                if ($('#ddlEstadoCivil')[0].selectedIndex < 1) {
                    step1();
                    exibeCampoObrigatorio($('#ddlEstadoCivil'));
                    $('#ddlEstadoCivil').focus();
                    return false;
                }

                if ($('#txtPai').val().trim() == "") {
                    step1();
                    exibeCampoObrigatorio($('#txtPai'));
                    $('#txtPai').focus();
                    return false;
                }

                if ($('#txtMae').val().trim() == "") {
                    step1();
                    exibeCampoObrigatorio($('#txtMae'));
                    $('#txtMae').focus();
                    return false;
                }

                if ($('#ddlEstadoCivil option:selected').text() == "Casado(a)" || $('#ddlEstadoCivil option:selected').text() == "Vive Maritalmente" || $('#ddlEstadoCivil option:selected').text() == "Companheiro(a)") {
                    if ($('#txtConjuge').val().trim() == "") {
                        step1();
                        exibeCampoObrigatorio($('#txtConjuge'));
                        $('#txtConjuge').focus();
                        return false;
                    }
                }

                if ($('#ddlEscolaridade')[0].selectedIndex < 1) {
                    step1();
                    exibeCampoObrigatorio($('#ddlEscolaridade'));
                    $('#ddlEscolaridade').focus();
                    return false;
                }

                if ($('#ddlProfissao')[0].selectedIndex < 1) {
                    step1();
                    exibeCampoObrigatorio($('#ddlProfissao'));
                    $('#ddlProfissao').focus();
                    return false;
                }

            }

            return true;

        }

        function validaDadosListaEndereco() {

            var listaEnd = $('input#hdnListaEnderecos').val();
            if (listaEnd == "") {

                var valida = validaDadosEndereco();
                if (valida) {
                    insereListaEnderecos();
                    listaEnd = $.parseJSON($('input#hdnListaEnderecos').val());
                }
                else
                    return false;

            }
            else {
                listaEnd = $.parseJSON(listaEnd);
            }

            var validaComercial = false;
            var validaResidencial = false;
            var validaCobranca = false;
            for (var i = 0; i < listaEnd.length; i++) {

                if (Usuario == "PF") {
                    if (listaEnd[i].TipoEndereco == "Residencial" && listaEnd[i].Ativo) {
                        validaResidencial = true;
                    }
                }
                else {
                    if (listaEnd[i].TipoEndereco == "Comercial" && listaEnd[i].Ativo) {
                        validaComercial = true;
                    }
                }

                if (listaEnd[i].EEnderecoCobranca && listaEnd[i].Ativo) {
                    validaCobranca = true;
                }

            }

            if (Usuario == "PJ") {
                if (!validaComercial) {
                    $('#divValidaEnderecos').slideDown();
                    $('#msgValidaEnderecos').text('Informe um endereço comercial.');

                    setTimeout(function () {
                        $('#divValidaEnderecos').slideUp();
                    }, 5000);
                    $('#txtCep').focus();

                    return false;
                }
            }
            else {
                if (!validaResidencial) {
                    $('#divValidaEnderecos').slideDown();
                    $('#msgValidaEnderecos').text('Informe um endereço residencial.');

                    setTimeout(function () {
                        $('#divValidaEnderecos').slideUp();
                    }, 5000);
                    $('#txtCep').focus();

                    return false;
                }
            }
            if (!validaCobranca) {
                $('#divValidaEnderecos').slideDown();
                $('#msgValidaEnderecos').text('Informe um endereço para cobrança.');

                setTimeout(function () {
                    $('#divValidaEnderecos').slideUp();
                }, 5000);
                $('#txtCep').focus();

                return false;
            }

            return true;
        }

        function validaDadosListaContato() {

            var listaEmails = $('input#hdnListaEmails').val();
            if (listaEmails == "") {
                var valida = validaDadosEmail();
                if (valida) {

                    if ($('#chkEPrincipal').prop("checked")) {
                        insereListaEmails();
                        listaEmails = $.parseJSON($('input#hdnListaEmails').val());
                    }
                    else {
                        $('#divValidaEmails').slideDown();
                        setTimeout(function () {
                            $('#divValidaEmails').slideUp();
                        }, 5000);
                        $('#chkEPrincipal').focus();

                        return false;
                    }
                }
                else
                    return false;
            }
            else {
                listaEmails = $.parseJSON(listaEmails);
            }

            var validaEPrincipal = false;
            for (var i = 0; i < listaEmails.length; i++) {
                if (listaEmails[i].EPrincipal && listaEmails[i].Ativo) {
                    validaEPrincipal = true;
                }
            }

            if (!validaEPrincipal) {
                $('#divValidaEmails').slideDown();
                setTimeout(function () {
                    $('#divValidaEmails').slideUp();
                }, 5000);
                $('#txtEmail').focus();

                return false;
            }

            var listaTel = $('input#hdnListaTelefones').val();
            if (listaTel == "") {

                var valida = validaDadosTelefone();
                if (valida) {
                    insereListaTelefones();
                    listaTel = $.parseJSON($('input#hdnListaTelefones').val());
                }
                else
                    return false;

            }
            else {
                listaTel = $.parseJSON(listaTel);
            }

            var validaComercial = false;
            var validaResidencial = false;
            
            for (var i = 0; i < listaTel.length; i++) {

                if (Usuario == "PF") {
                    if (listaTel[i].Finalidade == "Residencial" && listaTel[i].Ativo) {
                        validaResidencial = true;
                    }
                }
                else {
                    if (listaTel[i].Finalidade == "Comercial" && listaTel[i].Ativo) {
                        validaComercial = true;
                    }
                }
            }

            if (Usuario == "PJ") {

                if (!validaComercial) {
                    $('#divValidaTelefones').slideDown();
                    $('#msgValidaTelefones').text('Informe um telefone comercial.');
                    setTimeout(function () {
                        $('#divValidaTelefones').slideUp();
                    }, 5000);
                    $('#ddlFinTelefone').focus();

                    return false;
                }

            }
            else {

                if (!validaResidencial) {
                    $('#divValidaTelefones').slideDown();
                    $('#msgValidaTelefones').text('Informe um telefone residencial.');

                    setTimeout(function () {
                        $('#divValidaTelefones').slideUp();
                    }, 5000);
                    $('#ddlFinTelefone').focus();

                    return false;
                }

            }

            return true;
        }

        function validaDadosEndereco() {
            var valida = true;

            if ($('#txtCep').val().trim() == "") {
                step2();
                exibeCampoObrigatorio($('#txtCep'));
                $('#txtCep').focus();
                return false;
            }

            if ($('#ddlTipoEndereco')[0].selectedIndex < 1) {
                step2();
                exibeCampoObrigatorio($('#ddlTipoEndereco'));
                $('#ddlTipoEndereco').focus();
                return false;
            }

            if ($('#ddlTipoEndereco option:selected').text() == "Comercial" && Usuario == "PF") {
                if ($('#txtNomeEmpresa').val().trim() == "") {
                    step2();
                    exibeCampoObrigatorio($('#txtNomeEmpresa'));
                    $('#txtNomeEmpresa').focus();
                    return false;
                }

                if ($('#ddlTipoEmpresa')[0].selectedIndex < 1) {
                    step2();
                    exibeCampoObrigatorio($('#ddlTipoEmpresa'));
                    $('#ddlTipoEmpresa').focus();
                    return false;
                }

                if ($('#ddlRegistradoCarteira')[0].selectedIndex < 1) {
                    step2();
                    exibeCampoObrigatorio($('#ddlRegistradoCarteira'));
                    $('#ddlRegistradoCarteira').focus();
                    return false;
                }

            }

            if ($('#txtEndereco').val().trim() == "") {
                step2();
                exibeCampoObrigatorio($('#txtEndereco'));
                $('#txtEndereco').focus();
                return false;
            }

            if ($('#txtNumero').val().trim() == "") {
                step2();
                exibeCampoObrigatorio($('#txtNumero'));
                $('#txtNumero').focus();
                return false;
            }

            //if ($('#txtComplemento').val().trim() == "") {
            //    step2();
            //    exibeCampoObrigatorio($('#txtComplemento'));
            //    $('#txtComplemento').focus();
            //    return false;
            //}

            if ($('#txtBairro').val().trim() == "") {
                step2();
                exibeCampoObrigatorio($('#txtBairro'));
                $('#txtBairro').focus();
                return false;
            }

            if ($('#txtCidade').val().trim() == "") {
                step2();
                exibeCampoObrigatorio($('#txtCidade'));
                $('#txtCidade').focus();
                return false;
            }

            if ($('#ddlEstado')[0].selectedIndex < 1) {
                step2();
                exibeCampoObrigatorio($('#ddlEstado'));
                $('#ddlEstado').focus();
                return false;
            }

            return valida;
        }

        function validaDadosEmail() {
            var valida = true;

            if ($('#txtEmail').val().trim() == "") {
                step3();
                exibeCampoObrigatorio($('#txtEmail'));
                $('#txtEmail').focus();
                return false;
            }

            if (!validaEmail($('#txtEmail').val().trim())) {
                step3();
                exibeCampoObrigatorio($('#txtEmail'), "Email inválido");
                $('#txtEmail').focus();
                return false;
            }
            
            if (EmailItem != null && EmailItem.Email == $('#txtEmail').val()){
                return valida;
            }

            var listaEmails = $('input#hdnListaEmails').val();
            if (listaEmails != "") {
                listaEmails = $.parseJSON(listaEmails);
                for (var i = 0; i < listaEmails.length; i++) {
                    if (listaEmails[i].Email == $('#txtEmail').val()) {
                        step3();
                        exibeCampoObrigatorio($('#txtEmail'), "Email já existe");
                        $('#txtEmail').focus();
                        return false;
                    }
                }
            }
            
            if (!validaEmailCliente($('#txtEmail').val().trim(), false)) {
                step3();
                exibeCampoObrigatorio($('#txtEmail'), "Email já existe");
                $('#txtEmail').focus();
                return false;
            }

            return valida;

        }

        function validaDadosTelefone() {
            var valida = true;

            if ($('#ddlFinTelefone')[0].selectedIndex < 1) {
                step3();
                exibeCampoObrigatorio($('#ddlFinTelefone'));
                $('#ddlFinTelefone').focus();
                return false;
            }

            if ($('#txtTelefone').val().trim() == "") {
                step3();
                exibeCampoObrigatorio($('#txtTelefone'));
                $('#txtTelefone').focus();
                return false;
            }

            if ($('#txtTelefone').val().trim().length < 14) {
                step3();
                exibeCampoObrigatorio($('#txtTelefone'));
                $('#txtTelefone').focus();
                return false;
            }

            if (TelefoneItem != null && TelefoneItem.Telefone == $('#txtTelefone').val()){
                return valida;
            }

            var listaTelefones = $('input#hdnListaTelefones').val();
            if (listaTelefones != "") {
                listaTelefones = $.parseJSON(listaTelefones);
                for (var i = 0; i < listaTelefones.length; i++) {
                    var tel = listaTelefones[i].CodTipoTelefone + ' (' + listaTelefones[i].DDD + ') ' + listaTelefones[i].Telefone  // { 'CodTelefone': codigo, 'Finalidade': finalidade, 'CodTipoTelefone': tipo, 'Telefone': telefone.substring(5).replace('-', ''), 'DDD': telefone.substring(1, 3), 'Referencia': referencia, 'Ativo': ativo };

                    if (tel == $('#ddlFinTelefone').val() + ' ' + $('#txtTelefone').val().replace('-','')) {
                        step3();
                        exibeCampoObrigatorio($('#txtTelefone'), "Telefone já existe");
                        $('#txtTelefone').focus();
                        return false;
                    }
                }
            }

            return valida;
        }

        function validaDadosResponsavel() {
            var valida = true;
            var listaResps = $('input#hdnListaResponsaveis').val();

            if (UsuarioOperacao == "Inclusao") {
                if (listaResps != "") {
                    listaResps = $.parseJSON(listaResps);
                    for (var i = 0; i < listaResps.length; i++) {
                        var cpf = $('#txtCpfResponsavel').val().replace(/[^\d]+/g, '');
                        if (listaResps[i].CPF == cpf) {
                            step1();
                            exibeCampoObrigatorio($('#txtCpfResponsavel'), "Responsável já existe");
                            $('#txtCpfResponsavel').focus();
                            return false;
                        }
                    }
                }
            }
            else if (UsuarioOperacao == "Alteracao") {
                if (listaResps != "") {
                    listaResps = $.parseJSON(listaResps);
                    for (var i = 0; i < listaResps.length; i++) {
                        var cpf = $('#txtCpfResponsavel').val().replace(/[^\d]+/g, '');
                        if (listaResps[i].CPF == cpf && listaResps[i].Ativo && ( ResponsavelItem == null || ResponsavelItem.CPF != cpf) ) {
                            step1();
                            exibeCampoObrigatorio($('#txtCpfResponsavel'), "Responsável já existe");
                            $('#txtCpfResponsavel').focus();
                            return false;
                        }
                    }
                }
            }

            if (listaResps == "") {
                if ($('#ddlTipoResponsavel')[0].selectedIndex < 1) {
                    step1();
                    exibeCampoObrigatorio($('#ddlTipoResponsavel'));
                    $('#ddlTipoResponsavel').focus();
                    return false;
                }

                if ($('#txtCpfResponsavel').val().trim() == "") {
                    step1();
                    exibeCampoObrigatorio($('#txtCpfResponsavel'));
                    $('#txtCpfResponsavel').focus();
                    return false;
                }

                if (!validaCpf($('#txtCpfResponsavel').val().trim())) {
                    step1();
                    exibeCampoObrigatorio($('#txtCpfResponsavel'), "CPF inválido");
                    $('#txtCpfResponsavel').focus();
                    return false;
                }

                if ($('#txtNomeResponsavel').val().trim() == "") {
                    step1();
                    exibeCampoObrigatorio($('#txtNomeResponsavel'));
                    $('#txtNomeResponsavel').focus();
                    return false;
                }

            }
            return valida;
        }

        function validaDadosCartao() {
            var valida = true;

            if ($('#txtNomeCartao').val().trim() == "") {
                step4();
                exibeCampoObrigatorio($('#txtNomeCartao'));
                $('#txtNomeCartao').focus();
                return false;
            }

            if ($('#txtRendaMensal').val() == "" || $('#txtRendaMensal').val() == "0,00") {
                step4();
                exibeCampoObrigatorio($('#txtRendaMensal'));
                $('#txtRendaMensal').focus();
                return false;
            }

            if ($('#txtLimiteConta').val().trim() == "") {
                step4();
                exibeCampoObrigatorio($('#txtLimiteConta'));
                $('#txtLimiteConta').focus();
                return false;
            }

            if ($('#txtLimiteProduto').val().trim() == "") {
                step4();
                exibeCampoObrigatorio($('#txtLimiteProduto'));
                $('#txtLimiteProduto').focus();
                return false;
            }

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
                step4();
                exibeCampoObrigatorio($('#txtLimiteProduto'), "O limite do produto não pode ser maior que o limite da conta");
                exibeError($('#txtLimiteConta'), true);
                $('#txtLimiteProduto').focus();
                return false;
            }

            if ($('#ddlTipoOperacaoCartao')[0].selectedIndex < 1) {
                step4();
                exibeCampoObrigatorio($('#ddlTipoOperacaoCartao'));
                $('#ddlTipoOperacaoCartao').focus();
                return false;
            }

            if ($('#ddlBandeira')[0].selectedIndex < 1) {
                step4();
                exibeCampoObrigatorio($('#ddlBandeira'));
                $('#ddlBandeira').focus();
                return false;
            }

            if ($('#ddlProduto option').length == 0) {
                step4();
                exibeCampoObrigatorio($('#ddlBandeira'), "A Bandeira <b>" + $("#ddlBandeira option:selected").text() + "</b> não possui Produto cadastrado");
                $('#ddlBandeira').focus();
                return false;
            }

            if ($('#ddlProduto')[0].selectedIndex < 1) {
                step4();
                exibeCampoObrigatorio($('#ddlProduto'));
                $('#ddlProduto').focus();
                return false;
            }

            var rendaProduto = ArrayRendaProduto[$('#ddlProduto').val()];
            var renda = retornaFloat($('#txtRendaMensal').val());

            if (renda < rendaProduto) {
                
                if (Usuario == "PJ")
                    exibeCampoObrigatorio($('#ddlProduto'), "O patrimônio liquido é insuficiente para o Produto <b>" + $("#ddlProduto option:selected").text() + "</b>");
                else
                    exibeCampoObrigatorio($('#ddlProduto'), "A renda mensal é insuficiente para o Produto <b>" + $("#ddlProduto option:selected").text() + "</b>");

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
                        step4();
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
                    step4();
                    if ($('#ddlGrupoTarifa option').length == 0)
                        exibeCampoObrigatorio($('#ddlGrupoTarifa'), "O Produto <b>" + $("#ddlProduto option:selected").text() + "</b> não possui <b>Grupo Tarifário</b> cadastrado");
                    else
                        exibeCampoObrigatorio($('#ddlGrupoTarifa'));
                    $('#ddlGrupoTarifa').focus();
                    return false;
                }

                if (!ArrayRendaGrupoTarifaDefault[$('#ddlGrupoTarifa').val()]) {
                    if ($('#txtVencimentoGrupoTarifario').val().trim() == "") {
                        step4();
                        exibeCampoObrigatorio($('#txtVencimentoGrupoTarifario'));
                        $('#txtVencimentoGrupoTarifario').focus();
                        return false;
                    }

                    if (!validaData($('#txtVencimentoGrupoTarifario').val().trim())) {
                        step4();
                        exibeCampoObrigatorio($('#txtVencimentoGrupoTarifario'), "Data inválida");
                        $('#txtVencimentoGrupoTarifario').focus();
                        return false;
                    }

                    if (comparaDataAtual($('#txtVencimentoGrupoTarifario').val().trim())) {
                        step4();
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
                step4();
                exibeCampoObrigatorio($('#ddlProduto'), "O Produto <b>" + $("#ddlProduto option:selected").text() + "</b> não possui Limites cadastrado");
                $('#ddlProduto').focus();
                return false;
            }

            if (!validaDadosBancarios()) {
                return false;
            }

            if ($('#ddlDiaVencimento')[0].selectedIndex < 1) {
                step4();
                exibeCampoObrigatorio($('#ddlDiaVencimento'));
                $('#ddlDiaVencimento').focus();
                return false;
            }

            //$('input#hdnDataVencimentoBandeira').val($('#txtDataVencimentoBandeira').val());
            //$('input#hdnDataVencimentoEmissor').val($('#txtDataVencimentoEmissor').val());
            $('input#hdnDataVencimentoBandeira').val($('#lblDataVencimentoBandeira').text());
            $('input#hdnDataVencimentoEmissor').val($('#lblDataVencimentoEmissor').text());

            if ($('#ddlBloqueadoExterior')[0].selectedIndex < 1) {
                step4();
                exibeCampoObrigatorio($('#ddlBloqueadoExterior'));
                $('#ddlBloqueadoExterior').focus();
                return false;
            }

            if ($('#ddlBloqueadoExterior option:selected').text() == "Não") {
                if ($('#txtFaixaIniBloqExt').val().trim() == "") {
                    step4();
                    exibeCampoObrigatorio($('#txtFaixaIniBloqExt'));
                    $('#txtFaixaIniBloqExt').focus();
                    return false;
                }
                if (!validaData($('#txtFaixaIniBloqExt').val().trim())) {
                    step4();
                    exibeCampoObrigatorio($('#txtFaixaIniBloqExt'), "Data inválida");
                    $('#txtFaixaIniBloqExt').focus();
                    return false;
                }
                if (comparaDataAtual($('#txtFaixaIniBloqExt').val().trim())) {
                    step4();
                    exibeCampoObrigatorio($('#txtFaixaIniBloqExt'), "Data inválida");
                    $('#txtFaixaIniBloqExt').focus();
                    return false;
                }

                if ($('#txtFaixaFimBloqExt').val().trim() == "") {
                    step4();
                    exibeCampoObrigatorio($('#txtFaixaFimBloqExt'));
                    $('#txtFaixaFimBloqExt').focus();
                    return false;
                }
                if (!validaData($('#txtFaixaFimBloqExt').val().trim())) {
                    step4();
                    exibeCampoObrigatorio($('#txtFaixaFimBloqExt'), "Data inválida");
                    $('#txtFaixaFimBloqExt').focus();
                    return false;
                }
                if (comparaDataAtual($('#txtFaixaFimBloqExt').val().trim())) {
                    step4();
                    exibeCampoObrigatorio($('#txtFaixaFimBloqExt'), "Data inválida");
                    $('#txtFaixaFimBloqExt').focus();
                    return false;
                }

                if (!comparaData($('#txtFaixaIniBloqExt').val().trim(), $('#txtFaixaFimBloqExt').val().trim())) {
                    step4();
                    exibeCampoObrigatorio($('#txtFaixaIniBloqExt'), "A data incial não pode ser maior que a data final");
                    $('#txtFaixaIniBloqExt').focus();
                    return false;
                }

            }
            else {
                $('#txtFaixaIniBloqExt').val('');
                $('#txtFaixaIniBloqExt').val('');
            }

            //if ($('#ddlStatusCartao')[0].selectedIndex < 1) {
            //    step4();
            //    exibeCampoObrigatorio($('#ddlStatusCartao'));
            //    $('#ddlStatusCartao').focus();
            //    return false;
            //}

            //if ($('#ddlStatusCartao option:selected').text() == "Bloqueado") {
            //    if ($('#ddlTipoBloqueio')[0].selectedIndex < 1) {
            //        step4();
            //        exibeCampoObrigatorio($('#ddlTipoBloqueio'));
            //        $('#ddlTipoBloqueio').focus();
            //        return false;
            //    }

            //}

            return valida;
        }

        function validaDadosBancarios() {
            var valida = true;

            if ($('#ddlDebAutomatico')[0].selectedIndex < 1) {
                step4();
                exibeCampoObrigatorio($('#ddlDebAutomatico'));
                $('#ddlDebAutomatico').focus();
                return false;
            }

            if (DivConta) {
                if ($('#ddlBanco')[0].selectedIndex < 1) {
                    step4();
                    exibeCampoObrigatorio($('#ddlBanco'));
                    $('#ddlBanco').focus();
                    return false;
                }

                if ($('#txtAgencia').val().trim() == "") {
                    step4();
                    exibeCampoObrigatorio($('#txtAgencia'));
                    $('#txtAgencia').focus();
                    return false;
                }

                if ($('#txtContaCorrente').val().trim() == "") {
                    step4();
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

        function insereListaEnderecos() {
            $('#divListaEnderecos').slideUp();

            var cep = $('#txtCep').val().trim();
            var tipoEndereco = $('#ddlTipoEndereco option:selected').text();
            var codTipoEndereco = $('#ddlTipoEndereco option:selected').val();
            var nomeEmpresa = $('#txtNomeEmpresa').val().trim();
            var codTipoEmpresa = $('#ddlTipoEmpresa option:selected').val();
            var registradoCarteira = false;
            if ($('#ddlRegistradoCarteira option:selected').text() == "Sim")
                registradoCarteira = true;
            if (tipoEndereco != "Comercial") {
                nomeEmpresa = null;
                codTipoEmpresa = null;
                registradoCarteira = null;
            }

            var endereco = $('#txtEndereco').val().trim();
            var numero = $('#txtNumero').val().trim();
            var complemento = $('#txtComplemento').val().trim();
            var bairro = $('#txtBairro').val().trim();
            var cidade = $('#txtCidade').val().trim();
            var estado = $('#ddlEstado option:selected').val();
            var cobranca = $('#chkCobranca').prop("checked");

            // verificamos se já existe um principal
            if (cobranca) {
                var listaEndereco = $('input#hdnListaEnderecos').val();
                if (listaEndereco != "") {
                    listaEndereco = $.parseJSON(listaEndereco);
                    var validaCobranca = false;
                    for (var i = 0; i < listaEndereco.length; i++) {
                        if (listaEndereco[i].EEnderecoCobranca) {
                            validaCobranca = true;
                        }
                    }

                    if (validaCobranca) {
                        $('input#hdnListaEnderecos').val('');
                        $("#table-enderecos tbody tr").remove();

                        for (var i = 0; i < listaEndereco.length; i++) {
                            var cep = listaEndereco[i].CEP
                            if (cep.indexOf("-") == -1)
                                cep = cep.substring(0, 5) + "-" + cep.substring(5);

                            insereTableEnderecos(listaEndereco[i].CodEndereco, cep, listaEndereco[i].CodTipoEndereco, listaEndereco[i].TipoEndereco, listaEndereco[i].Logradouro, listaEndereco[i].Numero, listaEndereco[i].Complemento, listaEndereco[i].Bairro, listaEndereco[i].Municipio, listaEndereco[i].UF, false, listaEndereco[i].CodTipoEmpresa, listaEndereco[i].NomeEmpresa, listaEndereco[i].RegistradoCarteira, listaEndereco[i].Ativo);

                        }
                    }
                }
            }

            insereTableEnderecos(0, cep, codTipoEndereco, tipoEndereco, endereco, numero, complemento, bairro, cidade, estado, cobranca, codTipoEmpresa, nomeEmpresa, registradoCarteira, true);

            $('#divListaEnderecos').slideDown();

            $('#txtCep').val('');
            $('#ddlTipoEndereco').val('');
            $('#ddlTipoEmpresa').val('');
            $('#txtNomeEmpresa').val('');
            $('#ddlRegistradoCarteira').val('');
            $('#txtEndereco').val('');
            $('#txtNumero').val('');
            $('#txtComplemento').val('');
            $('#txtBairro').val('');
            $('#txtCidade').val('');
            $('#ddlEstado').val('');
            $('#chkCobranca').prop("checked", false);

            $('#txtCep').focus();

        }

        function alteraListaEnderecos() {
            $('#divListaEnderecos').slideUp();

            var listaEndereco = $('input#hdnListaEnderecos').val();
            listaEndereco = $.parseJSON(listaEndereco);

            var cod_end = EnderecoItem.CodEndereco;
            var txt_logradouro = EnderecoItem.Logradouro;

            var end = listaEndereco.filter(function (item, i) {
                if (item.CodEndereco == cod_end && item.Logradouro == txt_logradouro) {
                    return item;
                }
            });

            if (end != null && end.length > 0 && end[0].CodEndereco !== undefined) {

                var ecobranca = $('#chkCobranca').prop("checked");

                // verificamos se já existe um endereço de cobrança
                if (ecobranca) {
                    for (var i = 0; i < listaEndereco.length; i++) {
                        listaEndereco[i].EEnderecoCobranca = false;
                    }
                }

                end[0].CEP = $('#txtCep').val().trim();
                end[0].CodTipoEndereco = $('#ddlTipoEndereco option:selected').val();
                end[0].NomeEmpresa = $('#txtNomeEmpresa').val().trim();  
                end[0].CodTipoEmpresa = $('#ddlTipoEmpresa option:selected').val();
                end[0].RegistradoCarteira = false;
                if ($('#ddlRegistradoCarteira option:selected').text() == "Sim")
                    end[0].RegistradoCarteira = true;  
                end[0].Logradouro = $('#txtEndereco').val().trim();
                end[0].Numero = $('#txtNumero').val().trim();
                end[0].Complemento = $('#txtComplemento').val().trim();
                end[0].Bairro = $('#txtBairro').val().trim();
                end[0].Municipio = $('#txtCidade').val().trim();
                end[0].UF = $('#ddlEstado option:selected').val();
                end[0].EEnderecoCobranca = ecobranca;
            }

            UsuarioTitular.Endereco = listaEndereco;
            geraTableEnderecos();

            $('#divListaEnderecos').slideDown();
            $('#txtCep').val('');
            $('#ddlTipoEndereco').val('');
            $('#ddlTipoEmpresa').val('');
            $('#txtNomeEmpresa').val('');
            $('#ddlRegistradoCarteira').val('');
            $('#txtEndereco').val('');
            $('#txtNumero').val('');
            $('#txtComplemento').val('');
            $('#txtBairro').val('');
            $('#txtCidade').val('');
            $('#ddlEstado').val('');
            $('#chkCobranca').prop("checked", false);

            $('#txtCep').focus();

        }

        function insereTableEnderecos(codigo, cep, codTipoEndereco, tipoEndereco, endereco, numero, complemento, bairro, cidade, estado, cobranca, codTipoEmpresa, nomeEmpresa, registradoCarteira, ativo) {

            if (ativo) {
                var indice = $("#table-enderecos tr").length

                var logradouro = endereco + ", " + numero + ' ' + complemento + " - " + bairro + "<br> CEP:" + cep + " - " + cidade + "/" + estado;

                var text = "<tr>";
                text += "   <td>" + indice + "</td>";
                text += "   <td>" + tipoEndereco + "</td>";
                text += "   <td>" + logradouro + "</td>";
                if (cobranca)
                    text += "   <td style='text-align:center'><span class='glyphicon glyphicon-check' data-toggle='tooltip' data-placement='top' title='endereço de cobrança' /></td>";
                else
                    text += "   <td style='text-align:center'><span class='glyphicon glyphicon-unchecked' data-toggle='tooltip' data-placement='top' title='' /></td>";

                var data_logradouro = endereco + ';' + numero + ';' + cep.replace('-','');
                text += "   <td style='cursor: pointer;'><span class='glyphicon glyphicon-edit color-blue alterarItemEndereco' data-cod_endereco='" + codigo + "' data-logradouro='" + data_logradouro + "' data-item='" + indice + "' data-toggle='tooltip' data-placement='top' title='editar' />&nbsp;&nbsp;<span class='glyphicon glyphicon-trash color-red removerItemEndereco' data-cod_endereco='" + codigo + "' data-logradouro='" + data_logradouro + "' data-item='" + indice + "' data-toggle='tooltip' data-placement='top' title='remover' /></td>";
                
                text += "</tr>";

                var table = $("#table-enderecos tbody");

                table.append(text);
            }

            var novoEnd = { 'CodEndereco': codigo, 'CEP': cep.replace('-', ''), 'CodTipoEndereco': codTipoEndereco, 'TipoEndereco': tipoEndereco, 'Logradouro': endereco, 'Numero': numero, 'Complemento': complemento, 'Bairro': bairro, 'Municipio': cidade, 'UF': estado, 'EEnderecoCobranca': cobranca, 'CodTipoEmpresa': codTipoEmpresa, 'NomeEmpresa': nomeEmpresa, 'RegistradoCarteira': registradoCarteira, 'Ativo': ativo };

            var listaEnd = $('input#hdnListaEnderecos').val();
            if (listaEnd == "") {
                listaEnd = [];
            }
            else {
                listaEnd = $.parseJSON(listaEnd);
            }

            listaEnd.push(novoEnd);
            $('input#hdnListaEnderecos').val(JSON.stringify(listaEnd));

            $(".alterarItemEndereco").off("click").on("click", function () {
                $('.tooltip').hide();
                exibeError($('#txtCep'), false);
                exibeError($('#ddlTipoEndereco'), false);
                exibeError($('#txtNomeEmpresa'), false);
                exibeError($('#ddlTipoEmpresa'), false);
                exibeError($('#ddlRegistradoCarteira'), false);
                exibeError($('#txtEndereco'), false);
                exibeError($('#txtNumero'), false);
                exibeError($('#txtComplemento'), false);
                exibeError($('#txtBairro'), false);
                exibeError($('#txtCidade'), false);
                exibeError($('#ddlEstado'), false);
                exibeError($('#chkCobranca'), false);
                
                EnderecoItem = null;

                var item_end = $(this).attr('data-item');
                var cod_end = $(this).attr('data-cod_endereco');
                var data_logradouro = $(this).attr('data-logradouro');

                var listaEndereco = $('input#hdnListaEnderecos').val();
                listaEndereco = $.parseJSON(listaEndereco);

                var end = listaEndereco.filter(function (item, i) {
                    var logradouro = item.Logradouro + ';' + item.Numero + ';' + item.CEP
                    if (item.CodEndereco == cod_end && logradouro == data_logradouro) {
                        item_end = i;
                        return item;
                    }
                });

                if (end != null && end.length > 0) {
                    var cep = end[0].CEP.substring(0, 5) + "-" + end[0].CEP.substring(5);
                    $('#txtCep').val(cep);
                    $('#ddlTipoEndereco').val(end[0].CodTipoEndereco);
                    $('#txtNomeEmpresa').val(end[0].NomeEmpresa);
                    $('#ddlTipoEmpresa').val(end[0].CodTipoEmpresa);
                    if (end[0].RegistradoCarteira)
                        $('#ddlRegistradoCarteira').val('S');
                    else
                        $('#ddlRegistradoCarteira').val('N');

                    $('#txtEndereco').val(end[0].Logradouro);
                    $('#txtNumero').val(end[0].Numero);
                    $('#txtComplemento').val(end[0].Complemento);
                    $('#txtBairro').val(end[0].Bairro);
                    $('#txtCidade').val(end[0].Municipio);
                    $('#ddlEstado').val(end[0].UF);
                    $('#chkCobranca').prop("checked", end[0].EEnderecoCobranca);

                    EnderecoItem  = end[0];

                    if ($('#ddlTipoEndereco option:selected').text().toLowerCase() == "comercial" && Usuario == "PF") {
                        $('#divComercial').slideDown();
                    }
                    else {
                        $('#divComercial').slideUp();
                    }

                    $("#table-enderecos tbody tr").removeClass();
                    $(this).parent().parent().addClass('info');

                    $('#btnIncluirEndereco').html('<i class="fa fa-check"></i> Alterar Endereço');
                    $('#btnCancelarEndereco').fadeIn("slow");

                }

            });

            $(".removerItemEndereco").off("click").on("click", function () {
                $('.tooltip').hide();
                $('#divListaEnderecos').slideUp();

                $('#btnCancelarEndereco').trigger("click");

                var item_end = $(this).attr('data-item');
                var cod_end = $(this).attr('data-cod_endereco');
                var data_logradouro = $(this).attr('data-logradouro');

                var listaEndereco = $('input#hdnListaEnderecos').val();
                listaEndereco = $.parseJSON(listaEndereco);

                var end = listaEndereco.filter(function (item, i) {
                    var logradouro = item.Logradouro + ';' + item.Numero + ';' + item.CEP
                    if (item.CodEndereco == cod_end && data_logradouro == logradouro) {
                        item_end = i;
                        return item;
                    }
                });

                if (end != null && end.length > 0 && end[0].CodEndereco !== undefined) {
                    if (end[0].CodEndereco == 0)
                        listaEndereco.splice(item_end, 1);
                    else
                        end[0].Ativo = false
                }

                $('input#hdnListaEnderecos').val('');
                $("#table-enderecos tbody tr").remove();

                if (listaEndereco.length > 0) {
                    var text = "";
                    for (var i = 0; i < listaEndereco.length; i++) {
                        var cep = listaEndereco[i].CEP.substring(0, 5) + "-" + listaEndereco[i].CEP.substring(5);
                        insereTableEnderecos(listaEndereco[i].CodEndereco, cep, listaEndereco[i].CodTipoEndereco, listaEndereco[i].TipoEndereco, listaEndereco[i].Logradouro, listaEndereco[i].Numero, listaEndereco[i].Complemento, listaEndereco[i].Bairro, listaEndereco[i].Municipio, listaEndereco[i].UF, listaEndereco[i].EEnderecoCobranca, listaEndereco[i].CodTipoEmpresa, listaEndereco[i].NomeEmpresa, listaEndereco[i].RegistradoCarteira, listaEndereco[i].Ativo);
                    }

                    var existeItem = false
                    for (var i = 0; i < listaEndereco.length; i++) {
                        if (listaEndereco[i].Ativo) {
                            existeItem = true;
                        }
                    }

                    if (existeItem)
                        $('#divListaEnderecos').slideDown();

                }

            });

        }

        function geraTableEnderecos() {
            $('.tooltip').hide();
            $('#divListaEnderecos').slideUp();

            if (UsuarioTitular.Endereco == null)
                return;

            var listaEndereco = UsuarioTitular.Endereco

            $.each(listaEndereco, function (index, item) {
                $.each($('#ddlTipoEndereco option'), function (i, TipoEndereco) {
                    if (item.CodTipoEndereco == TipoEndereco.value) {
                        item.TipoEndereco = TipoEndereco.text;
                    }
                });
            });

            $('input#hdnListaEnderecos').val('');
            $("#table-enderecos tbody tr").remove();

            if (listaEndereco.length > 0) {
                var text = "";
                for (var i = 0; i < listaEndereco.length; i++) {
                    var cep = listaEndereco[i].CEP
                    if (cep.indexOf("-") == -1)
                        cep = cep.substring(0, 5) + "-" + cep.substring(5);

                    insereTableEnderecos(listaEndereco[i].CodEndereco, cep, listaEndereco[i].CodTipoEndereco, listaEndereco[i].TipoEndereco, listaEndereco[i].Logradouro, listaEndereco[i].Numero, listaEndereco[i].Complemento, listaEndereco[i].Bairro, listaEndereco[i].Municipio, listaEndereco[i].UF, listaEndereco[i].EEnderecoCobranca, listaEndereco[i].CodTipoEmpresa, listaEndereco[i].NomeEmpresa, listaEndereco[i].RegistradoCarteira, listaEndereco[i].Ativo);
                }

                $('#chkCobranca').prop("checked", false);
                $('#divListaEnderecos').slideDown();

            }
        
        }

        function insereListaEmails() {
            $('#divListaEmails').slideUp();

            var email = $('#txtEmail').val().trim();
            var eprincipal = $('#chkEPrincipal').prop("checked");

            // verificamos se já existe um principal
            if (eprincipal) {
                var listaEmail = $('input#hdnListaEmails').val();
                if (listaEmail != "") {
                    listaEmail = $.parseJSON(listaEmail);
                    var validaEPrincipal = false;
                    for (var i = 0; i < listaEmail.length; i++) {
                        if (listaEmail[i].EPrincipal) {
                            validaEPrincipal = true;
                        }
                    }

                    if (validaEPrincipal) {
                        $('input#hdnListaEmails').val('');
                        $("#table-emails tbody tr").remove();

                        for (var i = 0; i < listaEmail.length; i++) {
                            var codigo_email = listaEmail[i].CodEmail;
                            var valor_email = listaEmail[i].Email;
                            
                            var ativo_email = listaEmail[i].Ativo;
                            var principal_email = false;

                            insereTableEmails(codigo_email, valor_email, principal_email, ativo_email);

                        }
                    }
                }
            }

            insereTableEmails(0, email, eprincipal, true);

            $('#divListaEmails').slideDown();

            $('#txtEmail').val('');
            $('#chkEPrincipal').prop("checked", false);

            $('#txtEmail').focus();

        }

        function alteraListaEmails() {
            $('#divListaEmails').slideUp();

            var listaEmail = $('input#hdnListaEmails').val();
            listaEmail = $.parseJSON(listaEmail);

            var eprincipal = $('#chkEPrincipal').prop("checked");            

            // verificamos se já existe um principal
            if (eprincipal) {
                var validaEPrincipal = false;
                for (var i = 0; i < listaEmail.length; i++) {
                    if (listaEmail[i].EPrincipal) {
                        validaEPrincipal = true;
                    }
                }

                if (validaEPrincipal) {
                    $('input#hdnListaEmails').val('');
                    $("#table-emails tbody tr").remove();

                    for (var i = 0; i < listaEmail.length; i++) {
                        var codigo_email = listaEmail[i].CodEmail;
                        var valor_email = listaEmail[i].Email;
                        var ativo_email = listaEmail[i].Ativo;
                        var principal_email = false;

                        insereTableEmails(codigo_email, valor_email, principal_email, ativo_email);

                    }

                    listaEmail = $('input#hdnListaEmails').val();
                    listaEmail = $.parseJSON(listaEmail);

                }
            }

            var cod_email = EmailItem.CodEmail;
            var txt_email = EmailItem.Email;

            var email = listaEmail.filter(function (item, i) {
                if (item.CodEmail == cod_email && item.Email == txt_email) {
                    return item;
                }
            });

            if (email != null && email.length > 0 && email[0].CodEmail !== undefined) {
                email[0].Email = $('#txtEmail').val().trim();
                email[0].EPrincipal = $('#chkEPrincipal').prop("checked");
                email[0].Ativo = true;
            }

            UsuarioTitular.Email = listaEmail;
            geraTableEmails();

            $('#txtEmail').val('');
            $('#chkEPrincipal').prop("checked", false);

            $('#txtEmail').focus();

        }

        function insereTableEmails(codigo, email, eprincipal, ativo) {

            if (ativo) {
                var indice = $("#table-emails tr").length

                var text = "<tr>";
                text += "   <td>" + indice + "</td>";
                text += "   <td>" + email + "</td>";
                if (eprincipal)
                    text += "   <td style='text-align:center'><span class='glyphicon glyphicon-check' data-toggle='tooltip' data-placement='top' title='email principal' /></td>";
                else
                    text += "   <td style='text-align:center'><span class='glyphicon glyphicon-unchecked' data-toggle='tooltip' data-placement='top' title='email adicional' /></td>";

                text += "   <td style='cursor: pointer;'><span class='glyphicon glyphicon-edit color-blue alterarItemEmail' data-cod_email='" + codigo + "' data-email='" + email + "' data-item='" + indice + "' data-toggle='tooltip' data-placement='top' title='editar' />&nbsp;&nbsp;<span class='glyphicon glyphicon-trash color-red removerItemEmail' data-cod_email='" + codigo + "' data-email='" + email + "' data-item='" + indice + "' data-toggle='tooltip' data-placement='top' title='remover' /></td>";
                text += "</tr>";

                var table = $("#table-emails tbody");

                table.append(text);
            }

            var novoEmail = { 'CodEmail': codigo, 'Email': email, 'EPrincipal': eprincipal, Ativo: ativo};

            var listaEmail = $('input#hdnListaEmails').val();
            if (listaEmail == "") {
                listaEmail = [];
            }
            else {
                listaEmail = $.parseJSON(listaEmail);
            }

            listaEmail.push(novoEmail);

            $('input#hdnListaEmails').val(JSON.stringify(listaEmail));

            $(".alterarItemEmail").off("click").on("click", function () {
                $('.tooltip').hide();
                exibeError($('#txtEmail'), false);
                
                EmailItem = null;

                var item_email = $(this).attr('data-item');
                var cod_email = $(this).attr('data-cod_email');
                var txt_email = $(this).attr('data-email');

                var listaEmail = $('input#hdnListaEmails').val();
                listaEmail = $.parseJSON(listaEmail);

                var email = listaEmail.filter(function (item, i) {
                    if (item.CodEmail == cod_email && item.Email == txt_email) {
                        item_email = i;
                        return item;
                    }
                });

                if (email != null && email.length > 0) {
                    $('#txtEmail').val(email[0].Email);
                    $('#chkEPrincipal').prop("checked", email[0].EPrincipal);

                    EmailItem = email[0];

                    $("#table-emails tr").removeClass();
                    $(this).parent().parent().addClass('info');

                    $('#btnIncluirEmail').html('<i class="fa fa-check"></i> Alterar Email');
                    $('#btnCancelarEmail').fadeIn("slow");

                }

            });

            $(".removerItemEmail").off("click").on("click", function () {
                $('.tooltip').hide();
                $('#divListaEmails').slideUp();

                $('#btnCancelarEmail').trigger("click");

                var item_email = $(this).attr('data-item');
                var cod_email = $(this).attr('data-cod_email');
                var txt_email = $(this).attr('data-email');

                var listaEmail = $('input#hdnListaEmails').val();
                listaEmail = $.parseJSON(listaEmail);

                var email = listaEmail.filter(function (item, i) {
                    if (item.CodEmail == cod_email && item.Email == txt_email) {
                        item_email = i;
                        return item;
                    }
                });

                if (email != null && email.length > 0 && email[0].CodEmail !== undefined) {
                    if (email[0].CodEmail == 0)
                        listaEmail.splice(item_email, 1);
                    else
                        email[0].Ativo = false
                }

                $('input#hdnListaEmails').val('');
                $("#table-emails tbody tr").remove();

                if (listaEmail.length > 0) {
                    var text = "";
                    for (var i = 0; i < listaEmail.length; i++) {
                        var codigo = listaEmail[i].CodEmail;
                        var email = listaEmail[i].Email;
                        var eprincipal = listaEmail[i].EPrincipal;
                        var ativo = listaEmail[i].Ativo;

                        insereTableEmails(codigo, email, eprincipal, ativo);

                    }

                    var existeItem = false
                    for (var i = 0; i < listaEmail.length; i++) {
                        if (listaEmail[i].Ativo) {
                            existeItem = true;
                        }
                    }

                    if (existeItem)
                        $('#divListaEmails').slideDown();

                }

            });

        }

        function geraTableEmails() {

            $('.tooltip').hide();
            $('#divListaEmails').slideUp();

            if (UsuarioTitular.Email == null)
                return;

            var listaEmail = UsuarioTitular.Email;
            
            $('input#hdnListaEmails').val('');
            $("#table-emails tbody tr").remove();

            if (listaEmail.length > 0) {
                var text = "";
                for (var i = 0; i < listaEmail.length; i++) {
                    var codigo = listaEmail[i].CodEmail;
                    var email = listaEmail[i].Email;
                    var eprincipal = listaEmail[i].EPrincipal;
                    var ativo = listaEmail[i].Ativo;

                    insereTableEmails(codigo, email, eprincipal, ativo);

                }

                $('#chkEPrincipal').prop("checked", false);
                $('#divListaEmails').slideDown();

            }
        }

        function insereTableTelefones(codigo, finalidade, tipo, telefone, referencia, ativo) {

            if (ativo) {
                var indice = $("#table-telefones tr").length

                var text = "<tr>";
                text += "   <td>" + indice + "</td>";
                text += "   <td>" + finalidade + "</td>";
                text += "   <td>" + telefone + "</td>";
                text += "   <td>" + referencia + "</td>";
                text += "   <td style='cursor: pointer;'><span class='glyphicon glyphicon-edit color-blue alterarItemTelefone' data-cod_telefone='" + codigo + "' data-telefone='" + telefone + "' data-tipo='" + tipo + "' data-item='" + indice + "' data-toggle='tooltip' data-placement='top' title='editar' />&nbsp;&nbsp;<span class='glyphicon glyphicon-trash color-red removerItemTelefone' data-cod_telefone='" + codigo + "' data-telefone='" + telefone + "' data-tipo='" + tipo + "' data-item='" + indice + "' data-toggle='tooltip' data-placement='top' title='remover' /></td>";
                text += "</tr>";

                var table = $("#table-telefones tbody");

                table.append(text);
            }

            var novoTel = { 'CodTelefone': codigo, 'Finalidade': finalidade, 'CodTipoTelefone': tipo, 'Telefone': telefone.substring(5).replace('-', ''), 'DDD': telefone.substring(1, 3), 'Referencia': referencia, 'Ativo': ativo };

            var listaTel = $('input#hdnListaTelefones').val();
            if (listaTel == "") {
                listaTel = [];
            }
            else {
                listaTel = $.parseJSON(listaTel);
            }

            listaTel.push(novoTel);

            $('input#hdnListaTelefones').val(JSON.stringify(listaTel));

            $(".alterarItemTelefone").off("click").on("click", function () {
                $('.tooltip').hide();
                exibeError($('#ddlFinTelefone'), false);
                exibeError($('#txtTelefone'), false);
                exibeError($('#txtObservacao'), false);
                
                TelefoneItem = null;

                var item_telefone = $(this).attr('data-item');
                var cod_telefone = $(this).attr('data-cod_telefone');
                var tipo_telefone = $(this).attr('data-tipo');
                var txt_telefone = $(this).attr('data-telefone').substring(5).replace(/[^\d]+/g, '');;
                var ddd_telefone = $(this).attr('data-telefone').substring(1, 3).replace(/[^\d]+/g, '');;

                var listaTelefone = $('input#hdnListaTelefones').val();
                listaTelefone = $.parseJSON(listaTelefone);

                var telefone = listaTelefone.filter(function (item, i) {
                    if (item.CodTelefone == cod_telefone && item.CodTipoTelefone == tipo_telefone && item.Telefone == txt_telefone && item.DDD == ddd_telefone) {
                        item_telefone = i;
                        return item;
                    }
                });

                if (telefone != null && telefone.length > 0) {
                    $('#ddlFinTelefone').val(telefone[0].CodTipoTelefone);
                    var tel = '';
                    if (telefone[0].Telefone.length == 9) {
                        tel = telefone[0].Telefone.substring(0, 5) + '-' + telefone[0].Telefone.substring(5);
                    }
                    else {
                        tel = telefone[0].Telefone.substring(0, 4) + '-' + telefone[0].Telefone.substring(4);
                    }
                    tel = '(' + telefone[0].DDD + ') ' + tel;

                    $('#txtTelefone').val(tel);
                    $('#txtObservacao').val(telefone[0].Referencia);

                    TelefoneItem = telefone[0];

                    $("#table-telefones tr").removeClass();
                    $(this).parent().parent().addClass('info');

                    $('#btnIncluirTelefone').html('<i class="fa fa-check"></i> Alterar Telefone');
                    $('#btnCancelarTelefone').fadeIn("slow");

                }

            });

            $(".removerItemTelefone").off("click").on("click", function () {
                $('.tooltip').hide();
                $('#divListaTelefones').slideUp();

                var item_telefone = $(this).attr('data-item');
                var cod_telefone = $(this).attr('data-cod_telefone');
                var tipo_telefone = $(this).attr('data-tipo');
                var txt_telefone = $(this).attr('data-telefone').substring(5).replace(/[^\d]+/g, '');;
                var ddd_telefone = $(this).attr('data-telefone').substring(1, 3).replace(/[^\d]+/g, '');;

                var listaTelefone = $('input#hdnListaTelefones').val();
                listaTelefone = $.parseJSON(listaTelefone);

                var tel = listaTelefone.filter(function (item, i) {
                    if (item.CodTelefone == cod_telefone && item.CodTipoTelefone == tipo_telefone && item.Telefone == txt_telefone && item.DDD == ddd_telefone) {
                        item_telefone = i;
                        return item;
                    }
                });

                if (tel != null && tel.length > 0 && tel[0].CodTelefone !== undefined) {
                    if (tel[0].CodTelefone == 0)
                        listaTelefone.splice(item_telefone, 1);
                    else
                        tel[0].Ativo = false
                }

                $('input#hdnListaTelefones').val('');
                $("#table-telefones tbody tr").remove();

                if (listaTelefone.length > 0) {
                    var text = "";
                    for (var i = 0; i < listaTelefone.length; i++) {
                        var codigo = listaTelefone[i].CodTelefone;
                        var finalidade = listaTelefone[i].Finalidade;
                        var tipo = listaTelefone[i].CodTipoTelefone;
                        var ativo = listaTelefone[i].Ativo;
                        if (listaTelefone[i].Telefone.length == 9) {
                            listaTelefone[i].Telefone = listaTelefone[i].Telefone.substring(0, 5) + '-' + listaTelefone[i].Telefone.substring(5);
                        }
                        else {
                            listaTelefone[i].Telefone = listaTelefone[i].Telefone.substring(0, 4) + '-' + listaTelefone[i].Telefone.substring(4);
                        }
                        var telefone = '(' + listaTelefone[i].DDD + ') ' + listaTelefone[i].Telefone;
                        var referencia = listaTelefone[i].Referencia;

                        insereTableTelefones(codigo, finalidade, tipo, telefone, referencia, ativo);

                    }

                    $('#divListaTelefones').slideDown();

                }

            });

        }

        function insereListaTelefones() {
            $('#divListaTelefones').slideUp();

            var finalidade = $('#ddlFinTelefone option:selected').text();
            var tipo = $('#ddlFinTelefone option:selected').val();
            var telefone = $('#txtTelefone').val().trim();
            var referencia = $('#txtObservacao').val().trim();

            insereTableTelefones(0, finalidade, tipo, telefone, referencia, true);

            $('#divListaTelefones').slideDown();
            $('#ddlFinTelefone').val('');
            $('#txtTelefone').val('');
            $('#txtObservacao').val('');

            $('#ddlFinTelefone').focus();

        }

        function alteraListaTelefones() {
            $('#divListaTelefones').slideUp();

            var listaTelefone = $('input#hdnListaTelefones').val();
            listaTelefone = $.parseJSON(listaTelefone);

            var cod_telefone = TelefoneItem.CodTelefone;
            var tipo_telefone = TelefoneItem.CodTipoTelefone;
            var txt_telefone = TelefoneItem.Telefone;
            var ddd_telefone = TelefoneItem.DDD;
            
            var telefone = listaTelefone.filter(function (item, i) {
                if (item.CodTelefone == cod_telefone && item.CodTipoTelefone == tipo_telefone && item.Telefone == txt_telefone && item.DDD == ddd_telefone) {
                    return item;
                }
            });

            if (telefone != null && telefone.length > 0 && telefone[0].CodTelefone !== undefined) {
                telefone[0].CodTipoTelefone = $('#ddlFinTelefone option:selected').val();
                telefone[0].Finalidade = $('#ddlFinTelefone option:selected').text();
                telefone[0].Telefone = $('#txtTelefone').val().trim().substring(5).replace('-', '');
                telefone[0].DDD = $('#txtTelefone').val().trim().substring(1, 3);
                telefone[0].Referencia = $('#txtObservacao').val().trim();
                telefone[0].Ativo = true;
            }

            UsuarioTitular.Telefone = listaTelefone;
            geraTableTelefones();

            $('#txtTelefone').val('');
            $('#ddlFinTelefone').val('');
            $('#txtObservacao').val('');

            $('#txtTelefone').focus();

        }

        function geraTableTelefones() {
            $('.tooltip').hide();
            $('#divListaTelefones').slideUp();

            if (UsuarioTitular.Telefone == null)
                return;

            var listaTelefone = UsuarioTitular.Telefone

            $.each(listaTelefone, function (index, item) {

                $.each($('#ddlFinTelefone option'), function (i, TipoTelefone) {
                    if (item.CodTipoTelefone == TipoTelefone.value) {
                        item.Finalidade = TipoTelefone.text;
                    }
                });
            });

            $('input#hdnListaTelefones').val('');
            $("#table-telefones tbody tr").remove();

            if (listaTelefone.length > 0) {
                var text = "";
                for (var i = 0; i < listaTelefone.length; i++) {
                    var codigo = listaTelefone[i].CodTelefone;
                    var finalidade = listaTelefone[i].Finalidade;
                    var tipo = listaTelefone[i].CodTipoTelefone;
                    var ativo = listaTelefone[i].Ativo;
                    var telefone = '';
                    if (listaTelefone[i].Telefone.length == 9) {
                        telefone = listaTelefone[i].Telefone.substring(0, 5) + '-' + listaTelefone[i].Telefone.substring(5);
                    }
                    else {
                        telefone = listaTelefone[i].Telefone.substring(0, 4) + '-' + listaTelefone[i].Telefone.substring(4);
                    }
                    telefone = '(' + listaTelefone[i].DDD + ') ' + telefone;
                    var referencia = listaTelefone[i].Referencia;

                    insereTableTelefones(codigo, finalidade, tipo, telefone, referencia, ativo);

                }

                $('#divListaTelefones').slideDown();

            }

        }

        function insereTableResponsaveis(codigo, responsavel, tipo, cpf, nome, ativo) {

            if (ativo) {
                var indice = $("#table-responsaveis tr").length;

                var text = "<tr>";
                text += "   <td>" + indice + "</td>";
                text += "   <td>" + responsavel + "</td>";
                text += "   <td>" + cpf + "</td>";
                text += "   <td>" + nome + "</td>";
                text += "   <td style='cursor: pointer;'><span class='glyphicon glyphicon-edit color-blue alterarItemResponsavel' data-cod_responsavel='" + codigo + "' data-cpf_responsavel='" + cpf + "' data-item='" + indice + "' data-toggle='tooltip' data-placement='top' title='editar' />&nbsp;&nbsp;<span class='glyphicon glyphicon-trash color-red removerItemResponsavel' data-cod_responsavel='" + codigo + "' data-cpf_responsavel='" + cpf + "' data-item='" + indice + "' data-toggle='tooltip' data-placement='top' title='remover' /></td>";
                text += "</tr>";

                var table = $("#table-responsaveis tbody");

                table.append(text);
            }

            var novoResp = { 'CodResponsavel': codigo, 'Tipo': responsavel, 'CodTipo': tipo, 'CPF': cpf.replace('.', '').replace('.', '').replace('-', ''), 'Nome': nome, 'Ativo': ativo };

            var listaResp = $('input#hdnListaResponsaveis').val();
            if (listaResp == "") {
                listaResp = [];
            }
            else {
                listaResp = $.parseJSON(listaResp);
            }

            listaResp.push(novoResp);

            $('input#hdnListaResponsaveis').val(JSON.stringify(listaResp));

            $(".alterarItemResponsavel").off("click").on("click", function () {
                $('.tooltip').hide();
                exibeError($('#ddlTipoResponsavel'), false);
                exibeError($('#txtCpfResponsavel'), false);
                exibeError($('#txtNomeResponsavel'), false);
                
                ResponsavelItem = null;

                var item_resp = $(this).attr('data-item');
                var cod_resp = $(this).attr('data-cod_responsavel');
                var cpf_resp = $(this).attr('data-cpf_responsavel');
                cpf_resp = cpf_resp.replace(/[^\d]+/g, '');

                var listaResponsavel = $('input#hdnListaResponsaveis').val();
                listaResponsavel = $.parseJSON(listaResponsavel);

                var resp = listaResponsavel.filter(function (item, i) {
                    if (item.CodResponsavel == cod_resp && item.CPF == cpf_resp) {
                        item_resp = i;
                        return item;
                    }
                });

                if (resp != null && resp.length > 0) {
                    $('#ddlTipoResponsavel').val(resp[0].CodTipo);
                    var cpf = resp[0].CPF.substring(0, 3) + '.' + resp[0].CPF.substring(3, 6) + '.' + resp[0].CPF.substring(6, 9) + '-' + resp[0].CPF.substring(9);
                    $('#txtCpfResponsavel').val(cpf);
                    $('#txtNomeResponsavel').val(resp[0].Nome);
                    ResponsavelItem = resp[0];

                    $("#table-responsaveis tr").removeClass();
                    $(this).parent().parent().addClass('info');

                    $('#btnIncluirResponsavel').html('<i class="fa fa-check"></i> Alterar Responsável');
                    $('#btnCancelarResponsavel').fadeIn("slow");

                }

            });

            $(".removerItemResponsavel").off("click").on("click", function () {
                $('.tooltip').hide();
                $('#divListaResponsaveis').slideUp();

                $('#btnCancelarResponsavel').trigger("click");

                var item_resp = $(this).attr('data-item');
                var cod_resp = $(this).attr('data-cod_responsavel');
                var cpf_resp = $(this).attr('data-cpf_responsavel');
                cpf_resp = cpf_resp.replace(/[^\d]+/g, '');

                var listaResponsavel = $('input#hdnListaResponsaveis').val();
                listaResponsavel = $.parseJSON(listaResponsavel);

                var resp = listaResponsavel.filter(function (item, i) {
                    if (item.CodResponsavel == cod_resp && item.CPF == cpf_resp) {
                        item_resp = i;
                        return item;
                    }
                });

                if (resp != null && resp.length > 0 && resp[0].CodResponsavel !== undefined) {
                    if (resp[0].CodResponsavel == 0)
                        listaResponsavel.splice(item_resp, 1);
                    else
                        resp[0].Ativo = false
                }

                $('input#hdnListaResponsaveis').val('');
                $("#table-responsaveis tbody tr").remove();

                if (listaResponsavel.length > 0) {
                    var text = "";
                    for (var i = 0; i < listaResponsavel.length; i++) {
                        var codigo = listaResponsavel[i].CodResponsavel;
                        var resp = listaResponsavel[i].Tipo;
                        var cod = listaResponsavel[i].CodTipo;
                        var cpf = listaResponsavel[i].CPF.substring(0, 3) + '.' + listaResponsavel[i].CPF.substring(3, 6) + '.' + listaResponsavel[i].CPF.substring(6, 9) + '-' + listaResponsavel[i].CPF.substring(9);
                        var nome = listaResponsavel[i].Nome;
                        var ativo = listaResponsavel[i].Ativo;

                        insereTableResponsaveis(codigo, resp, cod, cpf, nome, ativo);

                    }

                    var existeItem = false
                    for (var i = 0; i < listaResponsavel.length; i++) {
                        if (listaResponsavel[i].Ativo) {
                            existeItem = true;
                        }
                    }

                    if (existeItem)
                        $('#divListaResponsaveis').slideDown();

                }

            });

        }

        function insereListaResponsaveis() {
            $('#divListaResponsaveis').slideUp();

            var responsavel = $('#ddlTipoResponsavel option:selected').text();
            var tipo = $('#ddlTipoResponsavel option:selected').val();
            var cpf = $('#txtCpfResponsavel').val().trim();
            var nome = $('#txtNomeResponsavel').val().trim();

            insereTableResponsaveis(0, responsavel, tipo, cpf, nome, true);

            $('#divListaResponsaveis').slideDown();
            $('#ddlTipoResponsavel').val('');
            $('#txtCpfResponsavel').val('');
            $('#txtNomeResponsavel').val('');

            $('#ddlTipoResponsavel').focus();

        }

        function alteraListaResponsaveis() {
            $('#divListaResponsaveis').slideUp();

            var listaResponsavel = $('input#hdnListaResponsaveis').val();
            listaResponsavel = $.parseJSON(listaResponsavel);

            var cod_resp = ResponsavelItem.CodResponsavel;
            var cpf_resp = ResponsavelItem.CPF;

            var resp = listaResponsavel.filter(function (item, i) {
                if (item.CodResponsavel == cod_resp && item.CPF == cpf_resp) {
                    return item;
                }
            });

            if (resp != null && resp.length > 0 && resp[0].CodResponsavel !== undefined) {
                resp[0].Tipo = $('#ddlTipoResponsavel option:selected').text();
                resp[0].CodTipo = $('#ddlTipoResponsavel option:selected').val();
                resp[0].CPF = retornaNumerico($('#txtCpfResponsavel').val().trim());
                resp[0].Nome = $('#txtNomeResponsavel').val().trim();
                resp[0].Ativo = true;
            }

            UsuarioTitular.PessoaJuridica.Responsavel = listaResponsavel;
            geraTableResponsaveis();

            $('#divListaResponsaveis').slideDown();
            $('#ddlTipoResponsavel').val('');
            $('#txtCpfResponsavel').val('');
            $('#txtNomeResponsavel').val('');

            $('#ddlTipoResponsavel').focus();

        }

        function geraTableResponsaveis() {
            $('.tooltip').hide();
            $('#divListaResponsaveis').slideUp();

            if (UsuarioTitular.PessoaJuridica.Responsavel == null)
                return;

            var listaResponsavel = UsuarioTitular.PessoaJuridica.Responsavel

            $.each(listaResponsavel, function (index, item) {

                $.each($('#ddlTipoResponsavel option'), function (i, TipoResponsavel) {
                    if (item.CodTipo == TipoResponsavel.value) {
                        item.Tipo = TipoResponsavel.text;
                    }
                });
            });

            $('input#hdnListaResponsaveis').val('');
            $("#table-responsaveis tbody tr").remove();

            if (listaResponsavel.length > 0) {
                var text = "";
                for (var i = 0; i < listaResponsavel.length; i++) {
                    var codigo = listaResponsavel[i].CodResponsavel;
                    var resp = listaResponsavel[i].Tipo;
                    var cod = listaResponsavel[i].CodTipo;
                    var cpf = listaResponsavel[i].CPF.substring(0, 3) + '.' + listaResponsavel[i].CPF.substring(3, 6) + '.' + listaResponsavel[i].CPF.substring(6, 9) + '-' + listaResponsavel[i].CPF.substring(9);
                    var nome = listaResponsavel[i].Nome;
                    var ativo = listaResponsavel[i].Ativo;

                    insereTableResponsaveis(codigo, resp, cod, cpf, nome, ativo);

                }

                $('#divListaResponsaveis').slideDown();

            }

        }

        function step1() {

            StepFormulario = 1;

            $('#btn-step1').attr('class', 'btn btn-info btn-circle btn-lg');
            $('#btn-step2').attr('class', 'btn btn-default btn-circle');
            $('#btn-step3').attr('class', 'btn btn-default btn-circle');
            $('#btn-step4').attr('class', 'btn btn-default btn-circle');

            $('#div-step2').attr('class', 'timeline-default');
            $('#div-step3').attr('class', 'timeline-default');
            $('#div-step4').attr('class', 'timeline-default');

            //$('#btnAnterior').hide();
            $("#btnAnterior").attr("disabled", "disabled");
            $('#btnConfirmar').html('Próximo <i class="fa fa-forward"></i>');
            $('#btnConfirmar').attr('class', 'btn btn-outline btn-primary');
            
            $('#dados-endereco').hide();
            $('#dados-contato').hide();
            $('#dados-cartao').hide();
            $('#dados-bancarios').hide();

            if (Usuario == "PJ") {
                $('#dados-cliente-pf').hide();
                //if (UsuarioOperacao == "Alteracao") {
                //    $('#dados-cliente-pj').attr('style', 'border: none');
                //}

                $('#dados-cliente-pj').fadeIn('slow');

            }
            else {
                $('#dados-cliente-pj').hide();

                //if (UsuarioOperacao == "Alteracao") {
                //    $('#dados-cliente-pf').attr('style', 'border: none');
                //}

                $('#dados-cliente-pf').fadeIn('slow');
            }

            //$('#txtCpf').focus();
            $("#btnConfirmar").blur();

        }

        function step2() {

            StepFormulario = 2;

            $('#btn-step1').attr('class', 'btn btn-info btn-circle');
            $('#btn-step2').attr('class', 'btn btn-info btn-circle btn-lg');
            $('#btn-step3').attr('class', 'btn btn-default btn-circle');
            $('#btn-step4').attr('class', 'btn btn-default btn-circle');

            $('#div-step2').attr('class', 'timeline-next');
            $('#div-step3').attr('class', 'timeline-default');
            $('#div-step4').attr('class', 'timeline-default');

            //$('#btnAnterior').show();
            $("#btnAnterior").removeAttr("disabled");
            $('#btnConfirmar').html('Próximo <i class="fa fa-forward"></i>');
            $('#btnConfirmar').attr('class', 'btn btn-outline btn-primary');
            
            $('#dados-cliente-pf').hide();
            $('#dados-cliente-pj').hide();
            $('#dados-cartao').hide();
            $('#dados-bancarios').hide();
            $('#dados-contato').hide();
            
            //if (UsuarioOperacao == "Alteracao") {
            //    $('#dados-endereco').attr('style', 'border: none');
            //}

            $('#dados-endereco').fadeIn('slow');

            //$('#txtCep').focus();
            $("#btnConfirmar").blur();

        }

        function step3() {

            StepFormulario = 3;

            $('#btn-step1').attr('class', 'btn btn-info btn-circle');
            $('#btn-step2').attr('class', 'btn btn-info btn-circle');
            $('#btn-step3').attr('class', 'btn btn-info btn-circle btn-lg');
            $('#btn-step4').attr('class', 'btn btn-default btn-circle');

            $('#div-step2').attr('class', 'timeline-next');
            $('#div-step3').attr('class', 'timeline-next');
            $('#div-step4').attr('class', 'timeline-default');

            //$('#btnAnterior').show();
            $("#btnAnterior").removeAttr("disabled");
            $('#btnConfirmar').html('Próximo <i class="fa fa-forward"></i>');
            $('#btnConfirmar').attr('class', 'btn btn-outline btn-primary');
            
            $('#dados-cliente-pf').hide();
            $('#dados-cliente-pj').hide();
            $('#dados-endereco').hide();
            $('#dados-cartao').hide();
            $('#dados-bancarios').hide();
            
            //if (UsuarioOperacao == "Alteracao") {
            //    $('#dados-contato').attr('style', 'border: none');
            //    $('#dados-email').attr('style', 'border: none');
            //    $('#dados-contato').attr('style', 'border: none');
            //}

            $('#dados-contato').fadeIn('slow');

            //$('#txtEmail').focus();
            $("#btnConfirmar").blur();

        }

        function step4() {

            StepFormulario = 4;

            $('#btn-step1').attr('class', 'btn btn-info btn-circle');
            $('#btn-step2').attr('class', 'btn btn-info btn-circle');
            $('#btn-step3').attr('class', 'btn btn-info btn-circle');
            $('#btn-step4').attr('class', 'btn btn-info btn-circle btn-lg');

            $('#div-step2').attr('class', 'timeline-next');
            $('#div-step3').attr('class', 'timeline-next');
            $('#div-step4').attr('class', 'timeline-next');

            //$('#btnAnterior').show();
            $("#btnAnterior").removeAttr("disabled");
            $('#btnConfirmar').html('Confirmar <i class="fa fa-check"></i>');
            $('#btnConfirmar').attr('class', 'btn btn-primary');
            
            $('#dados-cliente-pf').hide();
            $('#dados-cliente-pj').hide();
            $('#dados-endereco').hide();
            $('#dados-contato').hide();
            $('#dados-bancarios').hide();
            
            if (UsuarioOperacao == "Alteracao") {
                $('#dados-cartao').attr('style', 'border: none');
            }

            $('#dados-cartao').fadeIn('slow');

            //$('#ddlDebAutomatico').focus();
            $("#btnConfirmar").blur();

        }

    </script>
</head>
<body id="fadeIn">
    <form id="form1" autocomplete="off" runat="server">
    <asp:ScriptManager ID="ScriptManager" runat="server">
    </asp:ScriptManager>
    <asp:HiddenField ID="hdnTitular" runat="server" Value="" />
    <%--<asp:HiddenField ID="hdnTipoValorLimite" runat="server" Value="" />--%>
    <div class="container" >
        <div class="content">
            <div class="row">
                <div class="col-md-12">
                    <h3 id="divTitulo" class="page-header">
                        Cliente</h3>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="panel-body">
            <div id="divTimeLine" class="row display-none" >
                <center>
                    <button id="btn-step1" type="button" class="btn btn-info btn-circle btn-lg" data-toggle="tooltip"
                        data-placement="top" title="Dados do Cliente">
                        1</button>
                    <hr id="div-step2" class="timeline-default" />
                    <button id="btn-step2" type="button" class="btn btn-default btn-circle" data-toggle="tooltip"
                        data-placement="top" title="Dados de Endereço">
                        2</button>
                    <hr id="div-step3" class="timeline-default" />
                    <button id="btn-step3" type="button" class="btn btn-default btn-circle" data-toggle="tooltip"
                        data-placement="top" title="Dados de Contato">
                        3</button>
                    <hr id="div-step4" class="timeline-default" />
                    <button id="btn-step4" type="button" class="btn btn-default btn-circle" data-toggle="tooltip"
                        data-placement="top" title="Dados do Cartão">
                        4</button>
                </center>
                <br />
            </div>
            
                <ul class="nav nav-tabs display-none" id="divTabs">
                    <li class="tab-dados active"><a id="tab-step1" href="#tab-step1" data-toggle="tab">Dados do Cliente</a>
                    </li>
                    <li class="tab-dados"><a id="tab-step2" href="#tab-step2" data-toggle="tab">Dados de Endereço</a>
                    </li>
                    <li class="tab-dados"><a id="tab-step3" href="#tab-step3" data-toggle="tab">Dados de Contato</a>
                    </li>
                    <%--<li class="tab-dados"><a id="tab-step4" href="#" data-toggle="tab">Dados Bancários</a></li>--%>
                </ul>
            
            <div class="tab-content">
            <%--Dados do Cliente--%>
            <div id="divDadosClientePessoaFisica" class="display-none">
                <div id="dados-cliente-pf" class="panel panel-default">
                    <div class="panel-heading panel-font">
                        Dados do Cliente Pessoa Física
                    </div>
                    <div class="panel-body">
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label58" runat="server" Text="CPF do Cliente:" CssClass="control-label"></asp:Label>
                                    <asp:TextBox ID="txtCpf" runat="server" placeholder="CPF do cliente" data-required="true"
                                        Width="200" CssClass="form-control input-cpf"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label59" runat="server" Text="Número da Identidade:" CssClass="control-label"></asp:Label>
                                    <asp:TextBox ID="txtIdentidade" runat="server" MaxLength="20" Width="200" placeholder="Número da identidade"
                                        CssClass="form-control input-numeric" data-required="true"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <div class="form-inline">
                                        <asp:Label ID="Label60" runat="server" Text="Orgão Emissor:" Width="120" CssClass="control-label"></asp:Label>
                                        <asp:Label ID="Label1" runat="server" Text="UF Emissor:" Width="120" CssClass="control-label margin-left"></asp:Label>
                                    </div>
                                    <div class="form-inline">
                                        <asp:TextBox ID="txtOrgaoEmissor" runat="server" MaxLength="50" Width="120" data-required="true"
                                            placeholder="Orgão emissor" CssClass="form-control input-uppercase"></asp:TextBox>
                                        <asp:DropDownList ID="ddlUfOrgaoEmissor" runat="server" Width="120" data-required="true"
                                            CssClass="form-control margin-left">
                                            <asp:ListItem Text="Selecione" Value="" />
                                            <asp:ListItem Text="AC" Value="AC" />
                                            <asp:ListItem Text="AL" Value="AL" />
                                            <asp:ListItem Text="AP" Value="AP" />
                                            <asp:ListItem Text="AM" Value="AM" />
                                            <asp:ListItem Text="BA" Value="BA" />
                                            <asp:ListItem Text="CE" Value="CE" />
                                            <asp:ListItem Text="DF" Value="DF" />
                                            <asp:ListItem Text="ES" Value="ES" />
                                            <asp:ListItem Text="GO" Value="GO" />
                                            <asp:ListItem Text="MA" Value="MA" />
                                            <asp:ListItem Text="MT" Value="MT" />
                                            <asp:ListItem Text="MS" Value="MS" />
                                            <asp:ListItem Text="MG" Value="MG" />
                                            <asp:ListItem Text="PA" Value="PA" />
                                            <asp:ListItem Text="PB" Value="PB" />
                                            <asp:ListItem Text="PR" Value="PR" />
                                            <asp:ListItem Text="PE" Value="PE" />
                                            <asp:ListItem Text="PI" Value="PI" />
                                            <asp:ListItem Text="RJ" Value="RJ" />
                                            <asp:ListItem Text="RN" Value="RN" />
                                            <asp:ListItem Text="RS" Value="RS" />
                                            <asp:ListItem Text="RO" Value="RO" />
                                            <asp:ListItem Text="RR" Value="RR" />
                                            <asp:ListItem Text="SC" Value="SC" />
                                            <asp:ListItem Text="SP" Value="SP" />
                                            <asp:ListItem Text="SE" Value="SE" />
                                            <asp:ListItem Text="TO" Value="TO" />
                                        </asp:DropDownList>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="lblNomeUsu_" runat="server" Text="Nome do Cliente:" CssClass="control-label"></asp:Label>
                                    <asp:TextBox ID="txtNomeUsu" runat="server" MaxLength="150" placeholder="Nome do cliente"
                                        data-required="true" CssClass="form-control input-capitalize"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label16" runat="server" Text="Data de Nascimento:" CssClass="control-label"></asp:Label>
                                    <asp:TextBox ID="txtDtNascimento" runat="server" placeholder="Data de nascimento"
                                        Width="200" CssClass="form-control input-date" data-required="true"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <div class="form-inline">
                                        <asp:Label ID="Label18" runat="server" Text="Sexo:" Width="120" CssClass="control-label"></asp:Label>
                                        <asp:Label ID="Label17" runat="server" Text="Estado Civil:" Width="120" CssClass="control-label margin-left"></asp:Label>
                                    </div>
                                    <div class="form-inline">
                                        <asp:DropDownList ID="ddlSexo" runat="server" CssClass="form-control" Width="120"
                                            data-required="true">
                                            <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                            <asp:ListItem Text="Feminino" Value="1" />
                                            <asp:ListItem Text="Masculino" Value="2" />
                                        </asp:DropDownList>
                                        <asp:DropDownList ID="ddlEstadoCivil" runat="server" CssClass="form-control margin-left"
                                            Width="120" data-required="true">
                                            <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                        </asp:DropDownList>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="lblPai" runat="server" Text="Nome do Pai:" CssClass="control-label"></asp:Label>
                                    <asp:TextBox ID="txtPai" runat="server" MaxLength="150" placeholder="Nome do pai"
                                        data-required="true" CssClass="form-control input-capitalize"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label26" runat="server" Text="Nome da Mãe:" CssClass="control-label"></asp:Label>
                                    <asp:TextBox ID="txtMae" runat="server" MaxLength="150" placeholder="Nome da mãe"
                                        data-required="true" CssClass="form-control input-capitalize"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label30" runat="server" Text="Nome do Cônjuge:" CssClass="control-label"></asp:Label>
                                    <asp:TextBox ID="txtConjuge" runat="server" MaxLength="150" placeholder="Nome do cônjuge"
                                        data-required="true" CssClass="form-control input-capitalize"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label31" runat="server" Text="Grau de Escolaridade:" CssClass="control-label"></asp:Label>
                                    <asp:DropDownList ID="ddlEscolaridade" runat="server" CssClass="form-control" data-required="true"
                                        Width="200">
                                        <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label34" runat="server" Text="Profissão:" CssClass="control-label"></asp:Label>
                                    <asp:DropDownList ID="ddlProfissao" runat="server" CssClass="form-control" Width="200"
                                        data-required="true">
                                        <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div id="divDadosClientePessoaJuridica" class="display-none">
                <div id="dados-cliente-pj" class="panel panel-default">
                    <div class="panel-heading panel-font">
                        Dados do Cliente Pessoa Jurídica
                    </div>
                    <div class="panel-body">
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label45" runat="server" Text="CNPJ do Cliente:" CssClass="control-label"></asp:Label>
                                    <asp:TextBox ID="txtCnpj" runat="server" placeholder="CNPJ do cliente" Width="250"
                                        data-required="true" CssClass="form-control input-cnpj"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label47" runat="server" Text="Razão Social:" CssClass="control-label"></asp:Label>
                                    <asp:TextBox ID="txtRazaoSocial" runat="server" MaxLength="250" data-required="true"
                                        placeholder="Razão social" CssClass="form-control input-uppercase"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label46" runat="server" Text="Nome Fantasia:" CssClass="control-label"></asp:Label>
                                    <asp:TextBox ID="txtNomeFantasia" runat="server" MaxLength="250" placeholder="Nome fantasia"
                                        CssClass="form-control input-capitalize" data-required="true"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label49" runat="server" Text="Inscrição Municipal:" CssClass="control-label"></asp:Label>
                                    <asp:TextBox ID="txtInscMunicipal" runat="server" placeholder="Inscrição municipal"
                                        MaxLength="50" Width="200" data-required="true" CssClass="form-control input-alphanumeric"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label50" runat="server" Text="Inscrição Estadual:" CssClass="control-label"></asp:Label>
                                    <asp:TextBox ID="txtInscEstadual" runat="server" placeholder="Inscrição estadual"
                                        MaxLength="50" Width="200" CssClass="form-control input-alphanumeric" data-required="true"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label48" runat="server" Text="Data da Fundação:" CssClass="control-label"></asp:Label>
                                    <asp:TextBox ID="txtDataFundacao" runat="server" placeholder="Data da fundação" CssClass="form-control input-date"
                                        data-required="true" Width="200"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12">
                                <div class="panel panel-default">
                                    <div class="panel-heading panel-font">
                                        Dados do Responsável
                                    </div>
                                    <div class="panel-body">
                                        <div class="row">
                                            <div class="col-md-4">
                                                <div class="form-group">
                                                    <asp:Label ID="Label53" runat="server" Text="Tipo Responsável:" CssClass="control-label"></asp:Label>
                                                    <asp:DropDownList ID="ddlTipoResponsavel" runat="server" CssClass="form-control"
                                                        data-required="true" Width="200">
                                                        <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="form-group">
                                                    <asp:Label ID="Label51" runat="server" Text="CPF:" CssClass="control-label"></asp:Label>
                                                    <asp:TextBox ID="txtCpfResponsavel" runat="server" MaxLength="150" placeholder="CPF do responsável"
                                                        Width="200" data-required="true" CssClass="form-control input-cpf"></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="form-group">
                                                    <asp:Label ID="Label52" runat="server" Text="Nome:" CssClass="control-label"></asp:Label>
                                                    <asp:TextBox ID="txtNomeResponsavel" runat="server" MaxLength="150" placeholder="Nome do responsável"
                                                        data-required="true" CssClass="form-control input-capitalize"></asp:TextBox>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-md-12 align-right">
                                                <div class="form-group">
                                                    <button type="button" id="btnCancelarResponsavel" class="btn btn-default display-none">
                                                        <i class="fa fa-times"></i>&nbsp;Cancelar</button>
                                                    <button type="button" id="btnIncluirResponsavel" class="btn btn-info">
                                                        <i class="fa fa-plus"></i>&nbsp;Incluir Responsável</button>
                                                    <asp:HiddenField ID="hdnListaResponsaveis" runat="server" Value="" />
                                                </div>
                                            </div>
                                        </div>
                                        <div id="divValidaResponsaveis" class="alert alert-danger display-none">
                                            Informe ao menos um responsável.
                                        </div>
                                        <div id="divListaResponsaveis" class="row display-none">
                                            <div class="col-md-10 bs-glyphicons ">
                                                <table id="table-responsaveis" class="table table-hover">
                                                    <thead>
                                                        <tr>
                                                            <th style="width: 50px">
                                                                #
                                                            </th>
                                                            <th style="width: 200px;">
                                                                Tipo Responsável
                                                            </th>
                                                            <th style="width: 180px;">
                                                                CPF Responsável
                                                            </th>
                                                            <th>
                                                                Nome Responsável
                                                            </th>
                                                            <th style="width: 50px; text-align: center">
                                                                Ações
                                                            </th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
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
            
            <%--Dados de Endereço--%>
            <div id="dados-endereco" class="panel panel-default display-none">
                <div class="panel-heading panel-font">
                    Dados de Endereço
                </div>
                <div class="panel-body">
                    <div class="row">
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:Label ID="lblCEP" runat="server" Text="CEP:" CssClass="control-label"></asp:Label>
                                <div class="input-group" style="width: 180px">
                                    <asp:TextBox ID="txtCep" runat="server" MaxLength="9" placeholder="CEP" CssClass="form-control input-cep"
                                        data-required="true"></asp:TextBox>
                                    <span class="input-group-btn">
                                        <button id="btnCep" class="btn btn-info" type="button" style="height: 34px;">
                                            <i class="fa fa-search"></i>
                                        </button>
                                    </span>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:Label ID="Label29" runat="server" Text="Tipo Endereço:" CssClass="control-label"></asp:Label>
                                <asp:DropDownList runat="server" ID="ddlTipoEndereco" Width="200" CssClass="form-control"
                                    data-required="true">
                                    <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>
                    <div class="row display-none" id="divComercial">
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:Label ID="Label21" runat="server" Text="Nome da Empresa:" CssClass="control-label"></asp:Label>
                                <asp:TextBox ID="txtNomeEmpresa" runat="server" MaxLength="150" placeholder="Nome da empresa"
                                    data-required="true" CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:Label ID="Label38" runat="server" Text="Tipo de Empresa:" CssClass="control-label"></asp:Label>
                                <asp:DropDownList runat="server" ID="ddlTipoEmpresa" Width="200" CssClass="form-control"
                                    data-required="true">
                                    <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:Label ID="Label39" runat="server" Text="Registrado em Carteira:" CssClass="control-label"></asp:Label>
                                <asp:DropDownList runat="server" ID="ddlRegistradoCarteira" Width="200" CssClass="form-control"
                                    data-required="true">
                                    <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                    <asp:ListItem Text="Sim" Value="S" />
                                    <asp:ListItem Text="Não" Value="N" />
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:Label ID="Label2" runat="server" Text="Logradouro:" CssClass="control-label"></asp:Label>
                                <asp:TextBox ID="txtEndereco" runat="server" MaxLength="150" placeholder="Logradouro"
                                    data-required="true" CssClass="form-control input-capitalize"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:Label ID="Label13" runat="server" Text="Número:" CssClass="control-label"></asp:Label>
                                <asp:TextBox ID="txtNumero" runat="server" MaxLength="10" Width="200" placeholder="Número"
                                    data-required="true" CssClass="form-control input-numeric"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:Label ID="Label12" runat="server" Text="Complemento:" CssClass="control-label"></asp:Label>
                                <asp:TextBox ID="txtComplemento" runat="server" MaxLength="150" placeholder="Complemento"
                                    data-required="true" CssClass="form-control input-alphanumeric"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:Label ID="Label11" runat="server" Text="Bairro:" CssClass="control-label"></asp:Label>
                                <asp:TextBox ID="txtBairro" runat="server" MaxLength="150" placeholder="Bairro" data-required="true"
                                    CssClass="form-control input-capitalize"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:Label ID="Label4" runat="server" Text="Município:" CssClass="control-label"></asp:Label>
                                <asp:TextBox ID="txtCidade" runat="server" MaxLength="100" placeholder="Município"
                                    CssClass="form-control input-capitalize" data-required="true"></asp:TextBox>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:Label ID="Label3" runat="server" Text="Estado:" CssClass="control-label"></asp:Label>
                                <asp:DropDownList runat="server" ID="ddlEstado" CssClass="form-control" data-required="true">
                                    <asp:ListItem Text="Selecione" Value="" />
                                    <asp:ListItem Text="Acre" Value="AC" />
                                    <asp:ListItem Text="Alagoas" Value="AL" />
                                    <asp:ListItem Text="Amap&aacute;" Value="AP" />
                                    <asp:ListItem Text="Amazonas" Value="AM" />
                                    <asp:ListItem Text="Bahia" Value="BA" />
                                    <asp:ListItem Text="Cear&aacute;" Value="CE" />
                                    <asp:ListItem Text="Distrito Federal" Value="DF" />
                                    <asp:ListItem Text="Esp&iacute;rito Santo" Value="ES" />
                                    <asp:ListItem Text="Goi&aacute;s" Value="GO" />
                                    <asp:ListItem Text="Maranh&atilde;o" Value="MA" />
                                    <asp:ListItem Text="Mato Grosso" Value="MT" />
                                    <asp:ListItem Text="Mato Grosso do Sul" Value="MS" />
                                    <asp:ListItem Text="Minas Gerais" Value="MG" />
                                    <asp:ListItem Text="Par&aacute;" Value="PA" />
                                    <asp:ListItem Text="Para&iacute;ba" Value="PB" />
                                    <asp:ListItem Text="Paran&aacute;" Value="PR" />
                                    <asp:ListItem Text="Pernambuco" Value="PE" />
                                    <asp:ListItem Text="Piau&iacute;" Value="PI" />
                                    <asp:ListItem Text="Rio de Janeiro" Value="RJ" />
                                    <asp:ListItem Text="Rio Grande do Norte" Value="RN" />
                                    <asp:ListItem Text="Rio Grande do Sul" Value="RS" />
                                    <asp:ListItem Text="Rond&ocirc;nia" Value="RO" />
                                    <asp:ListItem Text="Roraima" Value="RR" />
                                    <asp:ListItem Text="Santa Catarina" Value="SC" />
                                    <asp:ListItem Text="S&atilde;o Paulo" Value="SP" />
                                    <asp:ListItem Text="Sergipe" Value="SE" />
                                    <asp:ListItem Text="Tocantins" Value="TO" />
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4">
                            <div class="form-group">
                                <div class="checkbox">
                                    <label>
                                        <input type="checkbox" runat="server" id="chkCobranca" checked="checked" />Cobrança
                                    </label>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-8 align-right">
                            <div class="form-group">
                                <button type="button" id="btnCancelarEndereco" class="btn btn-default display-none"> <i class="fa fa-times"></i>&nbsp;Cancelar</button>
                                <button type="button" id="btnIncluirEndereco" class="btn btn-info"><i class="fa fa-plus"></i>&nbsp;Incluir Endereço</button>
                                <asp:HiddenField ID="hdnListaEnderecos" runat="server" Value="" />
                            </div>
                        </div>
                    </div>
                    <hr />
                    <div id="divValidaEnderecos" class="alert alert-danger display-none">
                        <span id="msgValidaEnderecos">Informe um endereço residencial e para cobrança.</span>
                    </div>
                    <div id="divListaEnderecos" class="row display-none">
                        <div class="col-md-10 bs-glyphicons">
                            <table id="table-enderecos" class="table table-hover">
                                <thead>
                                    <tr>
                                        <th style="width: 50px">
                                            #
                                        </th>
                                        <th style="width: 200px">
                                            Tipo do Endereço
                                        </th>
                                        <th>
                                            Endereço
                                        </th>
                                        <th style="width: 100px; text-align: center">
                                            Cobrança
                                        </th>
                                        <th style="width: 50px; text-align: center">
                                            Ações
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            
            <%--Dados de Contato--%>
            <div id="dados-contato" class="display-none">
                <div id="dados-email" class="panel panel-default">
                    <div class="panel-heading panel-font">
                        Dados de Email
                    </div>
                    <div class="panel-body">
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label14" runat="server" Text="Email:" CssClass="control-label"></asp:Label>
                                    <div class="input-group">
                                        <asp:TextBox ID="txtEmail" runat="server" MaxLength="150" placeholder="E-mail" data-required="true"
                                            CssClass="form-control input-email"></asp:TextBox>
                                        <span class="input-group-addon">@</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" runat="server" id="chkEPrincipal" checked="checked" />Principal
                                        </label>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-8 align-right">
                                <div class="form-group">
                                    <button type="button" id="btnCancelarEmail" class="btn btn-default display-none"><i class="fa fa-times"></i>&nbsp;Cancelar</button>
                                    <button type="button" id="btnIncluirEmail" class="btn btn-info"><i class="fa fa-plus"></i>&nbsp;Incluir Email</button>
                                    <asp:HiddenField ID="hdnListaEmails" runat="server" Value="" />
                                </div>
                            </div>
                        </div>
                        <div id="divValidaEmails" class="alert alert-danger display-none">
                            Informe um e-mail principal para contato.
                        </div>
                        <div id="divListaEmails" class="row display-none">
                            <div class="col-md-8 bs-glyphicons ">
                                <table id="table-emails" class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th style="width: 50px">
                                                #
                                            </th>
                                            <th>
                                                Email
                                            </th>
                                            <th style="width: 100px; text-align: center">
                                                Principal
                                            </th>
                                            <th style="width: 50px; text-align: center">
                                                Ações
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
                <div  id="dados-email" class="panel panel-default">
                    <div class="panel-heading panel-font">
                        Dados de Telefone
                    </div>
                    <div class="panel-body">
                        <div class="row">
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label33" runat="server" Text="Finalidade do Telefone:" CssClass="control-label"></asp:Label>
                                    <asp:DropDownList runat="server" ID="ddlFinTelefone" CssClass="form-control" data-required="true">
                                        <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label32" runat="server" Text="Telefone:" CssClass="control-label"></asp:Label>
                                    <asp:TextBox ID="txtTelefone" runat="server" MaxLength="150" placeholder="Telefone"
                                        data-required="true" CssClass="form-control input-phone"></asp:TextBox>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <div class="form-group">
                                    <asp:Label ID="Label19" runat="server" Text="Observação:" CssClass="control-label"></asp:Label>
                                    <asp:TextBox ID="txtObservacao" runat="server" MaxLength="150" placeholder="Observação"
                                        CssClass="form-control"></asp:TextBox>
                                </div>
                            </div>
                            <%--<div class="col-md-8">
                            <div class="form-group">
                                <asp:Label ID="Label20" runat="server" Text="Descrição da Referência:" CssClass="control-label"></asp:Label>
                                <asp:TextBox ID="txtDescricaoReferencia" runat="server" MaxLength="300" placeholder="Descrição da referência"
                                    CssClass="form-control"></asp:TextBox>
                            </div>
                        </div>--%>
                        </div>
                        <div class="row">
                            <div class="col-md-12 align-right">
                                <div class="form-group">
                                    <button type="button" id="btnCancelarTelefone" class="btn btn-default display-none"><i class="fa fa-times"></i>&nbsp;Cancelar</button>
                                    <button type="button" id="btnIncluirTelefone" class="btn btn-info"><i class="fa fa-plus"></i>&nbsp;Incluir Telefone</button>
                                    <asp:HiddenField ID="hdnListaTelefones" runat="server" Value="" />
                                </div>
                            </div>
                        </div>
                        <div id="divValidaTelefones" class="alert alert-danger display-none">
                            <span id="msgValidaTelefones">Informe um telefone</span>
                        </div>
                        <div id="divListaTelefones" class="row display-none">
                            <div class="col-md-12 bs-glyphicons ">
                                <table id="table-telefones" class="table table-hover">
                                    <thead>
                                        <tr>
                                            <th style="width: 50px">
                                                #
                                            </th>
                                            <th style="width: 150px">
                                                Finalidade
                                            </th>
                                            <th style="width: 200px">
                                                Telefone
                                            </th>
                                            <th>
                                                Observação
                                            </th>
                                            <th style="width: 50px; text-align: center">
                                                Ações
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            <%--Dados do Cartão--%>
            <div id="dados-cartao" class="panel panel-default display-none">
                <div class="panel-heading panel-font">
                    Dados do Cartão
                </div>
                <div class="panel-body">
                    <div class="row">
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:Label ID="Label15" runat="server" Text="Nome do Cliente no Cartão:" CssClass="control-label"></asp:Label>
                                <asp:TextBox ID="txtNomeCartao" runat="server" MaxLength="25" placeholder="Nome do cliente no cartão"
                                    data-required="true" CssClass="form-control input-uppercase"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:Label ID="lblRenda" runat="server" Text="Renda Mensal:" CssClass="control-label"></asp:Label>
                                <div class="input-group">
                                    <span class="input-group-addon">R$</span>
                                    <asp:TextBox ID="txtRendaMensal" runat="server" MaxLength="15" placeholder="Valor"
                                        data-required="true" CssClass="form-control input-money"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:Label ID="Label7" runat="server" Text="Limite Total da Conta:" CssClass="control-label"></asp:Label>
                                <div class="input-group">
                                    <span class="input-group-addon">R$</span>
                                    <asp:TextBox ID="txtLimiteConta" runat="server" MaxLength="15" placeholder="Limite total da conta"
                                        data-required="true" CssClass="form-control input-money"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        <div id="divLimiteProduto" class="col-md-4">
                            <div class="form-group">
                                <asp:Label ID="Label54" runat="server" Text="Limite do Produto:" CssClass="control-label"></asp:Label>
                                <div class="input-group">
                                    <span class="input-group-addon">R$</span>
                                    <asp:TextBox ID="txtLimiteProduto" runat="server" MaxLength="15" Width="157" placeholder="Limite do produto"
                                        data-required="true" CssClass="form-control input-money"></asp:TextBox>
                                </div>
                            </div>
                        </div>
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
                                <asp:DropDownList runat="server" ID="ddlProduto" data-required="true" CssClass="form-control"
                                    Width="200">
                                    <asp:ListItem Text="Selecione" Value="" Selected="True" />
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
                        <%--<div class="col-md-4" style="padding-right:100px; padding-top:20px" >
                            <div class="form-group">
                                <table>
                                <tr>
                                    <td>Total dos Limites: </td>
                                </tr>
                                <tr>
                                    <td><span id="infoTotalLimite" class="color-blue"></span></td>
                                </tr>
                                
                                <tr>
                                    <td>
                                        <hr />
                                    </td>
                                </tr>

                                <tr>
                                    <td>Total disponível: </td>
                                </tr>
                                <tr>
                                    <td><span id="infoTotalDisponivel" class="color-blue"></span></td>
                                </tr>

                                </table>
                                
                            </div>
                        </div>--%>
                        <div class="col-md-3">
                            <div class="form-group">
                                <asp:Label ID="Label27" runat="server" Text="Grupo Tarifário:" CssClass="control-label"></asp:Label>
                                <asp:DropDownList runat="server" ID="ddlGrupoTarifa" data-required="true" Width="200"
                                    CssClass="form-control">
                                    <asp:ListItem Text="Selecione" Value="" Selected="True" />
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
                                    <asp:ListItem Text="Selecione" Value="" Selected="True" />
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
                                <div class="input-group">
                                    <asp:DropDownList runat="server" ID="ddlDiaVencimento" Width="120" data-required="true"
                                        CssClass="form-control"> 
                                        <asp:ListItem Text="Selecione" Value="" Selected="True" /> 
                                    </asp:DropDownList> 
                                    <span class="input-inline" style="vertical-align:bottom">&nbsp;/&nbsp;</span>
                                    <%--<asp:TextBox ID="txtDiaFaturamento" runat="server" MaxLength="2" Width="60" data-required="true"
                                        CssClass="form-control" disabled></asp:TextBox>--%>
                                    <asp:Label ID="lblDiaFaturamento" runat="server" CssClass="control-label-box-default input-inline" Width="60">&nbsp;</asp:Label>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:Label ID="Label35" runat="server" Text="Vencimento Cartão Emissor:" CssClass="control-label"></asp:Label>
                                <asp:HiddenField ID="hdnDataVencimentoEmissor" runat="server" Value="" />
                                <%--<asp:TextBox ID="txtDataVencimentoEmissor" runat="server" placeholder="Data do Vencimento"
                                    Width="200" data-required="true" CssClass="form-control input-date" Enabled="false"></asp:TextBox>--%>
                                <asp:Label ID="lblDataVencimentoEmissor" runat="server" CssClass="control-label-box-default" Width="200"> </asp:Label>
                            </div>
                        </div>
                        <div class="col-md-4 display-none" id="divDataVencimentoBandeira">
                            <div class="form-group">
                                <asp:Label ID="Label36" runat="server" Text="Vencimento Cartão Bandeira:" CssClass="control-label"></asp:Label>
                                <asp:HiddenField ID="hdnDataVencimentoBandeira" runat="server" Value="" />
                                <%--<asp:TextBox ID="txtDataVencimentoBandeira" runat="server" placeholder="Data do Vencimento"
                                    Enabled="false" Width="200" data-required="true" CssClass="form-control input-date"></asp:TextBox>--%>
                                <asp:Label ID="lblDataVencimentoBandeira" runat="server" CssClass="control-label-box-default" Width="200"> </asp:Label>
                            </div>
                        </div>
                    </div>
                    <div class="row" style="margin-top: 5px">
                        <div class="col-md-4">
                            <div class="form-group">
                                <asp:Label ID="Label24" runat="server" Text="Bloqueado Exterior:" CssClass="control-label"></asp:Label>
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
                                <%--<asp:DropDownList ID="ddlStatusCartao" runat="server" CausesValidation="True" data-required="true"
                                    CssClass="form-control" Width="200px">
                                    <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                </asp:DropDownList>--%>
                                <asp:Label ID="lblStatusCartao" runat="server" CssClass="control-label-box-default" Width="200px">Bloqueado</asp:Label>
                            </div>
                        </div>
                        <div class="col-md-4" id="divTipoBloqueio" runat="server">
                            <div class="form-group">
                                <asp:Label ID="Label42" runat="server" Text="Motivo:" CssClass="control-label"></asp:Label>
                                <%--<asp:DropDownList ID="ddlTipoBloqueio" runat="server" CausesValidation="True" data-required="true"
                                    CssClass="form-control" Width="200px">
                                    <asp:ListItem Text="Selecione" Value="" Selected="True" />
                                </asp:DropDownList>--%>
                                <asp:Label ID="lblMotivo" runat="server" CssClass="control-label-box-default" Width="200px">Entrega</asp:Label>
                            </div>
                        </div>
                        <br />
                    </div>
                </div>
            </div>
            
            <%--Dados Bancários--%>
            <div id="dados-bancarios" class="panel panel-default display-none">
                <div class="panel-heading panel-font">
                    Dados Bancários
                </div>
                <div class="panel-body">
                </div>
            </div>

            </div>
        </div>
                    <div id="btn-inserir" class="row">
            <div class="col-md-6 align-right">
                <div class="form-group">
                    <button type="button" id="btnAnterior" class="btn btn-outline btn-default" disabled>
                        <i class="fa fa-backward"></i>
                        Anterior</button>
                </div>
            </div>
            <div class="col-md-6">
                <div class="form-group">
                    <asp:LinkButton ID="btnConfirmar" CssClass="btn btn-outline btn-primary" runat="server" OnClientClick="javascript:return validaFormulario();" OnClick="btnConfirmar_Click">Próximo <i class="fa fa-forward"></i></asp:LinkButton>
                </div>
            </div>
        </div>
                    <div id="btn-atualizar" class="row display-none">
            <div class="col-md-12 align-center">
                <div class="form-group">
                    <asp:LinkButton ID="btnConfirmar2" CssClass="btn btn-primary" runat="server" OnClientClick="javascript:return validaFormulario();" OnClick="btnConfirmar_Click">Confirmar <i class="fa fa-check"></i></asp:LinkButton>
                </div>
            </div>
        </div>
                    <div class="row row-margin">
            <div class="col-md-12">
                <a type="button" href="MenuTitular.aspx" id="btnVoltar" runat="server" class="btn btn-link">
                    Voltar</a>
            </div>
        </div>
                    <br />
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
                        Cliente Titular</h4>
                </div>
                <div class="modal-body align-center" style="font-size:18px !important;" id="MensagemSucesso">
                    Sucesso!
                    <br />
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
                        Cliente Titular</h4>
                </div>
                <div class="modal-body align-center" style="font-size:18px !important;" id="MensagemErro">
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
    
    $('#ddlBloqueadoExterior').val('1'); // "Não"

    $('#divFaixaIniBloqExt').fadeOut("slow");
    $('#divFaixaFimBloqExt').fadeOut("slow");

    //$('#ddlStatusCartao').val('2'); // "Bloqueado"
    //$('#ddlStatusCartao').attr("disabled", "disabled");

    //$('#divTipoBloqueio').fadeIn('slow')
    //$('#ddlTipoBloqueio').val('2'); // "Entrega"
    //$('#ddlTipoBloqueio').attr("disabled", "disabled");

    carregaUsuario();

    function carregaUsuario() {

        if (request("conta") != "") {

            UsuarioOperacao = "Alteracao";

            UsuarioTitular = $.parseJSON($('[id$=hdnTitular]').val());

            if (UsuarioTitular.PessoaJuridica != null) {
                Usuario = "PJ";
            }
            else {
                Usuario = "PF";
            }

            $('#dados-cliente-pj').attr('style', 'border: none');
            $('#dados-cliente-pf').attr('style', 'border: none');

            $('#dados-endereco').attr('style', 'border: none');
            $('#dados-contato').attr('style', 'border: none');
            $('#dados-email').attr('style', 'border: none');
            $('#dados-contato').attr('style', 'border: none');

            $('.panel-heading').hide();
            //$("#divTitulo").show();

            $("#divTabs").show();
            $("#divTimeLine").hide();

            $("#btn-inserir").hide();
            $("#btn-atualizar").show();

            step1();

        }
        else {
            Usuario = request("usuario").toUpperCase();

            UsuarioOperacao = "Inclusao";

            $("#divTimeLine").show();

            $("#btn-inserir").show();
            $("#btn-atualizar").hide();

        }

        if (Usuario == "PJ") {
            $("#divDadosClientePessoaJuridica").fadeIn('slow');
            $("#divDadosClientePessoaFisica").fadeOut('slow');
            $("#lblRenda").text('Patrimônio Liquido:');
            $("#divTitulo").text('Cliente Pessoa Jurídica');
        }
        else {
            $("#divDadosClientePessoaFisica").fadeIn('slow');
            $("#divDadosClientePessoaJuridica").fadeOut('slow');
            $("#lblRenda").text('Renda Mensal:');
            $("#divTitulo").text('Cliente Pessoa Física');
        }

        if (UsuarioOperacao == "Alteracao") {
            if (Usuario == "PJ") {
                $('#txtCnpj').val(UsuarioTitular.PessoaJuridica.CNPJPJ);
                $('#txtRazaoSocial').val(UsuarioTitular.PessoaJuridica.RazaoSocial);
                $('#txtNomeFantasia').val(UsuarioTitular.PessoaJuridica.NomeFantasia);
                if (UsuarioTitular.PessoaJuridica.DataFundacao != null)
                    $('#txtDataFundacao').val(toFormatString(new Date(UsuarioTitular.PessoaJuridica.DataFundacao)));
                $('#txtInscMunicipal').val(UsuarioTitular.PessoaJuridica.InscrMunicipal);
                $('#txtInscEstadual').val(UsuarioTitular.PessoaJuridica.InscrEstadual);

                var intervalTipoEndereco = setInterval(
            function () {
                if ($('#ddlTipoEndereco option').length > 1) {
                    $('#ddlTipoEndereco').val('');
                    clearInterval(intervalTipoEndereco);
                }
            }, 100);

                var intervalFinTelefone = setInterval(
            function () {
                if ($('#ddlFinTelefone option').length > 1) {
                    $('#ddlFinTelefone').val('');
                    clearInterval(intervalFinTelefone);
                }
            }, 100);

                var intervalResponsavel = setInterval(
            function () {
                if ($('#ddlTipoResponsavel option').length > 1) {
                    geraTableResponsaveis();
                    clearInterval(intervalResponsavel);
                }
            }, 100);

            }
            else {
                $('#txtCpf').val(UsuarioTitular.PessoaFisica.CPF);
                $('#txtIdentidade').val(UsuarioTitular.PessoaFisica.Identidade);
                $('#txtOrgaoEmissor').val(UsuarioTitular.PessoaFisica.OrgaoExpedidor);
                $('#ddlUfOrgaoEmissor').val(UsuarioTitular.PessoaFisica.UFOrgaoEmissor);
                $('#txtNomeUsu').val(UsuarioTitular.PessoaFisica.NomeCompleto);
                $('#txtDtNascimento').val(toLocaleDateString(UsuarioTitular.PessoaFisica.DataNasc));
                $('#ddlSexo').val(UsuarioTitular.PessoaFisica.CodSexo);
                //$('#ddlEstadoCivil').val(UsuarioTitular.PessoaFisica.CodEstadoCivil);
                $('#txtPai').val(UsuarioTitular.PessoaFisica.NomePai);
                $('#txtMae').val(UsuarioTitular.PessoaFisica.NomeMae);
                $('#txtConjuge').val(UsuarioTitular.PessoaFisica.Conjuge);
                //$('#ddlEscolaridade').val(UsuarioTitular.PessoaFisica.CodEscolaridade);
                //$('#ddlProfissao').val(UsuarioTitular.PessoaFisica.CodProfissao);

                var intervalTipoEndereco = setInterval(
            function () {
                if ($('#ddlTipoEndereco option').length > 1) {
                    $('#ddlTipoEndereco').val('');
                    clearInterval(intervalTipoEndereco);
                }
            }, 100);

                var intervalFinTelefone = setInterval(
            function () {
                if ($('#ddlFinTelefone option').length > 1) {
                    $('#ddlFinTelefone').val('');
                    clearInterval(intervalFinTelefone);
                }
            }, 100);

                var intervalEstadoCivil = setInterval(
            function () {
                if ($('#ddlEstadoCivil option').length > 1) {
                    $('#ddlEstadoCivil').val(UsuarioTitular.PessoaFisica.CodEstadoCivil);
                    clearInterval(intervalEstadoCivil);
                }
            }, 100);

                var intervalEscolaridade = setInterval(
            function () {
                if ($('#ddlEscolaridade option').length > 1) {
                    $('#ddlEscolaridade').val(UsuarioTitular.PessoaFisica.CodEscolaridade);
                    clearInterval(intervalEscolaridade);
                }
            }, 100);

                var intervalProfissao = setInterval(
            function () {
                if ($('#ddlProfissao option').length > 1) {
                    $('#ddlProfissao').val(UsuarioTitular.PessoaFisica.CodProfissao);
                    clearInterval(intervalProfissao);
                }
            }, 100);


            }

            var intervalEndereco = setInterval(
        function () {
            if ($('#ddlTipoEndereco option').length > 1) {
                geraTableEnderecos();
                clearInterval(intervalEndereco);
            }
        }, 100);

            geraTableEmails();

            var intervalTelefone = setInterval(
        function () {
            if ($('#ddlFinTelefone option').length > 1) {
                geraTableTelefones();
                clearInterval(intervalTelefone);
            }
        }, 100);

        }
}

</script>
</html>

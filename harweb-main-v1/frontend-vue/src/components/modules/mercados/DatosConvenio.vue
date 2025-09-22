<template>
  <div class="datos-convenio-page">
    <el-breadcrumb separator="/">
      <el-breadcrumb-item to="/">Inicio</el-breadcrumb-item>
      <el-breadcrumb-item>Convenios</el-breadcrumb-item>
      <el-breadcrumb-item>Detalle</el-breadcrumb-item>
    </el-breadcrumb>
    <el-card class="box-card" v-if="convenio">
      <div slot="header" class="clearfix">
        <span>Datos del Local Conveniado</span>
        <el-button style="float: right;" @click="$router.back()">Salir</el-button>
      </div>
      <el-row :gutter="20">
        <el-col :span="12">
          <el-form label-width="120px" :model="convenio" label-position="left">
            <el-form-item label="Tipo">
              <el-input v-model="convenio.descripcion" readonly></el-input>
            </el-form-item>
            <el-form-item label="SubTipo">
              <el-input v-model="convenio.desc_subtipo" readonly></el-input>
            </el-form-item>
            <el-form-item label="Nombre">
              <el-input v-model="convenio.nombre" readonly></el-input>
            </el-form-item>
            <el-form-item label="Calle">
              <el-input v-model="convenio.calle" readonly></el-input>
            </el-form-item>
            <el-form-item label="Num. Exterior">
              <el-input v-model="convenio.num_exterior" readonly></el-input>
            </el-form-item>
            <el-form-item label="Num. Interior">
              <el-input v-model="convenio.num_interior" readonly></el-input>
            </el-form-item>
            <el-form-item label="Inciso">
              <el-input v-model="convenio.inciso" readonly></el-input>
            </el-form-item>
            <el-form-item label="Convenio">
              <el-input v-model="convenio.convenio" readonly></el-input>
            </el-form-item>
            <el-form-item label="Vigencia">
              <el-input v-model="convenio.estado" readonly></el-input>
            </el-form-item>
            <el-form-item label="Observaciones">
              <el-input v-model="convenio.observaciones" readonly></el-input>
            </el-form-item>
          </el-form>
        </el-col>
        <el-col :span="12">
          <el-form label-width="120px" :model="convenio" label-position="left">
            <el-form-item label="Periodos">
              <el-input v-model="convenio.periodos" readonly></el-input>
            </el-form-item>
            <el-form-item label="Pago Total">
              <el-input v-model="convenio.total" readonly></el-input>
            </el-form-item>
            <el-form-item label="Renta Convenio">
              <el-input v-model="convenio.importe" readonly></el-input>
            </el-form-item>
            <el-form-item label="Pago Inicial">
              <el-input v-model="convenio.cantidad_inicio" readonly></el-input>
            </el-form-item>
            <el-form-item label="Pago Parcial">
              <el-input v-model="convenio.pago_parcial" readonly></el-input>
            </el-form-item>
            <el-form-item label="Pago Final">
              <el-input v-model="convenio.pago_final" readonly></el-input>
            </el-form-item>
            <el-form-item label="Recargos">
              <el-input v-model="convenio.recargos" readonly></el-input>
            </el-form-item>
            <el-form-item label="Gastos">
              <el-input v-model="convenio.gastos" readonly></el-input>
            </el-form-item>
            <el-form-item label="Multa">
              <el-input v-model="convenio.multa" readonly></el-input>
            </el-form-item>
            <el-form-item label="Pagos">
              <el-input v-model="convenio.total_pagos" readonly></el-input>
            </el-form-item>
            <el-form-item label="Tipo Pago">
              <el-input v-model="convenio.tipodesc" readonly></el-input>
            </el-form-item>
            <el-form-item label="Fecha Inicio">
              <el-input v-model="convenio.fecha_inicio" readonly></el-input>
            </el-form-item>
            <el-form-item label="Fecha Final">
              <el-input v-model="convenio.fecha_venc" readonly></el-input>
            </el-form-item>
          </el-form>
        </el-col>
      </el-row>
      <el-divider>Parcialidades</el-divider>
      <el-table :data="parciales" style="width: 100%" v-if="parciales.length">
        <el-table-column prop="pago_parcial_1" label="Parcial" width="80" />
        <el-table-column prop="descparc" label="Parcialidad" width="120" />
        <el-table-column prop="importe" label="Imp. Adeudo" width="120" />
        <el-table-column prop="peradeudos" label="Periodos" width="150" />
        <el-table-column prop="fecha_pago" label="Fecha Pago" width="110" />
        <el-table-column prop="oficina_pago" label="Rec. de Pago" width="110" />
        <el-table-column prop="caja_pago" label="Caja de Pago" width="110" />
        <el-table-column prop="operacion_pago" label="Oper. de Pago" width="110" />
      </el-table>
      <el-empty v-else description="No hay parcialidades registradas" />
    </el-card>
    <el-empty v-else description="Cargando convenio..." />
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'DatosConvenioPage',
  data() {
    return {
      convenio: null,
      parciales: [],
      loading: false
    };
  },
  created() {
    this.loadConvenio();
  },
  methods: {
    async loadConvenio() {
      this.loading = true;
      const id_conv = this.$route.params.id_conv;
      try {
        // Cargar datos generales
        const res = await axios.post('/api/execute', {
          action: 'getConvenioById',
          params: { id_conv }
        });
        this.convenio = res.data.data;
        // Cargar parcialidades
        const res2 = await axios.post('/api/execute', {
          action: 'getConvenioParciales',
          params: { id_conv }
        });
        this.parciales = res2.data.data;
      } catch (e) {
        this.$message.error('Error al cargar convenio: ' + (e.response?.data?.message || e.message));
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.datos-convenio-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 24px;
}
.box-card {
  margin-top: 24px;
}
</style>

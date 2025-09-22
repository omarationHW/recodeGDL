<template>
  <div class="cancelacion-masiva-page">
    <el-breadcrumb separator="/">
      <el-breadcrumb-item to="/">Inicio</el-breadcrumb-item>
      <el-breadcrumb-item>Convenios</el-breadcrumb-item>
      <el-breadcrumb-item>Cancelación Masiva</el-breadcrumb-item>
    </el-breadcrumb>
    <el-card class="box-card" shadow="hover">
      <div slot="header" class="clearfix">
        <span>Cancelación Masiva de Convenios</span>
      </div>
      <el-alert
        title="Se cancelan los convenios que fueron incumplidos bajo el siguiente criterio: A los 5 días hábiles de la segunda parcialidad vencida, con excepción de los convenios de licencias de construcción."
        type="info"
        show-icon
        :closable="false"
        class="mb-3"
      />
      <el-form :inline="true" :model="form" class="mb-2">
        <el-form-item label="Parcialidades vencidas">  
          <el-input-number v-model="form.vencidas" :min="2" :max="10" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="loading" @click="ejecutarCancelacion">Ejecutar Cancelación</el-button>
        </el-form-item>
        <el-form-item>
          <el-button type="default" @click="listarConvenios">Refrescar Lista</el-button>
        </el-form-item>
      </el-form>
      <el-alert v-if="mensaje" :title="mensaje" :type="mensajeTipo" show-icon class="mb-2" />
      <div class="mb-2">
        <strong>Convenios Cancelados: </strong>
        <el-tag type="success">{{ totalBajas }}</el-tag>
      </div>
      <el-table :data="bajas" style="width: 100%" stripe border>
        <el-table-column prop="tipo" label="Tipo" width="60" align="center" />
        <el-table-column prop="subtipo" label="Subtipo" width="80" align="center" />
        <el-table-column prop="letras_exp" label="Letras" width="80" align="center" />
        <el-table-column prop="numero_exp" label="Número" width="80" align="center" />
        <el-table-column prop="axo_exp" label="Año" width="70" align="center" />
        <el-table-column prop="fecha_inicio" label="Fecha Inicio" width="110" align="center" />
        <el-table-column prop="fecha_venc" label="Fecha Venc" width="110" align="center" />
        <el-table-column prop="aplicacion" label="Aplicación" width="160" align="center" />
        <el-table-column prop="referencia" label="Referencia" width="180" align="center" />
        <el-table-column prop="usuario" label="Usuario" width="100" align="center" />
      </el-table>
    </el-card>
  </div>
</template>

<script>
export default {
  name: 'CancelacionMasivaPage',
  data() {
    return {
      form: {
        vencidas: 2
      },
      bajas: [],
      totalBajas: 0,
      loading: false,
      mensaje: '',
      mensajeTipo: 'success'
    };
  },
  created() {
    this.listarConvenios();
  },
  methods: {
    async listarConvenios() {
      this.loading = true;
      this.mensaje = '';
      try {
        const resp = await this.$axios.post('/api/execute', {
          action: 'cancelacion_masiva_listar',
          params: {}
        });
        if (resp.data.success) {
          this.bajas = (resp.data.data || []).map(row => ({
            ...row,
            aplicacion: this.mapAplicacion(row.modulo)
          }));
          this.totalBajas = this.bajas.length;
        } else {
          this.mensaje = resp.data.message || 'Error al listar.';
          this.mensajeTipo = 'error';
        }
      } catch (e) {
        this.mensaje = 'Error de comunicación con el servidor.';
        this.mensajeTipo = 'error';
      } finally {
        this.loading = false;
      }
    },
    async ejecutarCancelacion() {
      this.loading = true;
      this.mensaje = '';
      try {
        const resp = await this.$axios.post('/api/execute', {
          action: 'cancelacion_masiva_ejecutar',
          params: {
            vencidas: this.form.vencidas
          }
        });
        if (resp.data.success) {
          this.mensaje = resp.data.message || 'Cancelación ejecutada.';
          this.mensajeTipo = 'success';
          await this.listarConvenios();
        } else {
          this.mensaje = resp.data.message || 'Error en la cancelación.';
          this.mensajeTipo = 'error';
        }
      } catch (e) {
        this.mensaje = 'Error de comunicación con el servidor.';
        this.mensajeTipo = 'error';
      } finally {
        this.loading = false;
      }
    },
    mapAplicacion(modulo) {
      switch (modulo) {
        case 3: return 'MULTA MUNICIPAL';
        case 4: return 'LICENCIA DE CONSTRUCCIÓN';
        case 5: return 'CUENTA PREDIAL';
        case 9: return 'LICENCIA DE GIRO';
        case 10: return 'LICENCIA DE ANUNCIO';
        case 11: return 'LOCAL DE MERCADO';
        case 16: return 'ASEO CONTRATADO';
        case 24: return 'ESTACIONAMIENTO PUBLICO';
        case 28: return 'ESTACIONAMIENTO EXCLUSIVO';
        default: return 'OTRO';
      }
    }
  }
};
</script>

<style scoped>
.cancelacion-masiva-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 24px;
}
.mb-2 { margin-bottom: 16px; }
.mb-3 { margin-bottom: 24px; }
</style>

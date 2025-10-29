<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Cons Pagos</h1>
        <p>Mercados - Gestión de Pagos</p>
      </div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <div class="cons-pagos-page">
          <el-breadcrumb separator="/">
            <el-breadcrumb-item to="/">Inicio</el-breadcrumb-item>
            <el-breadcrumb-item>Consulta de Pagos</el-breadcrumb-item>
          </el-breadcrumb>
          <el-card class="municipal-card">
            <div slot="header" class="clearfix">
              <span>Consulta de Pagos por Local</span>
            </div>
            <el-form :inline="true" :model="form" @submit.native.prevent="onBuscar">
              <el-form-item label="ID Local">
                <el-input v-model="form.id_local" placeholder="Ingrese el ID del local" />
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="onBuscar">Buscar</el-button>
              </el-form-item>
            </el-form>
            <el-table
              v-loading="loading"
              :data="pagos"
              style="width: 100%; margin-top: 20px"
              :empty-text="emptyText"
            >
              <el-table-column prop="id_local" label="Control" width="80" />
              <el-table-column prop="axo" label="Año" width="60" />
              <el-table-column prop="periodo" label="Mes" width="60" />
              <el-table-column prop="fecha_pago" label="Fecha" width="110" />
              <el-table-column prop="oficina_pago" label="Rec" width="60" />
              <el-table-column prop="caja_pago" label="Caja" width="60" />
              <el-table-column prop="operacion_pago" label="Oper." width="70" />
              <el-table-column prop="importe_pago" label="Renta" width="90" />
              <el-table-column prop="folio" label="Partida" width="100" />
              <el-table-column prop="fecha_modificacion" label="Actualización" width="120" />
              <el-table-column prop="usuario" label="Usuario" width="100" />
              <el-table-column label="Acciones" width="100">
                <template slot-scope="scope">
                  <el-button size="mini" type="danger" @click="onDelete(scope.row)">Eliminar</el-button>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'ConsPagos'"
      :moduleName="'mercados'"
      @close="closeDocumentation"
    />
  </div>
  <!-- /module-view -->
</template>

<script>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

export default {
  components: {
    DocumentationModal
  },
  name: 'ConsPagosPage',
  data() {
    return {
      form: {
        id_local: '',
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }},
      pagos: [],
      loading: false,
      emptyText: 'No hay pagos para este local',
      dialogVisible: false,
      newPago: {
        id_local: '',
        axo: '',
        periodo: '',
        fecha_pago: '',
        oficina_pago: '',
        caja_pago: '',
        operacion_pago: '',
        importe_pago: '',
        folio: '',
        id_usuario: 1 // Simulación, reemplazar por usuario real
      }
    }
  },
  methods: {
    openDocumentation() {
      this.showDocumentation = true;
    },
    closeDocumentation() {
      this.showDocumentation = false;
    },
    showToast(type, message) {
      this.toast = { show: true, type, message };
      setTimeout(() => this.hideToast(), 3000);
    },
    hideToast() {
      this.toast.show = false;
    },
    getToastIcon(type) {
      const icons = {
        success: 'check-circle',
        error: 'exclamation-circle',
        warning: 'exclamation-triangle',
        info: 'info-circle'
      };
      return icons[type] || 'info-circle';
    },
    async onBuscar() {
      if (!this.form.id_local) {
        this.$message.error('Debe ingresar el ID del local');
        return;
      }
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getPagosByLocal',
          params: { id_local: this.form.id_local }
        });
        if (res.data.success) {
          this.pagos = res.data.data;
        } else {
          this.$message.error(res.data.message || 'Error al consultar pagos');
        }
      } catch (e) {
        this.$message.error('Error de red');
      }
      this.loading = false;
    },
    async onAddPago() {
      this.newPago.id_local = this.form.id_local;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'addPago',
          params: this.newPago
        });
        if (res.data.success) {
          this.$message.success('Pago agregado');
          this.dialogVisible = false;
          this.onBuscar();
        } else {
          this.$message.error(res.data.message || 'Error al agregar pago');
        }
      } catch (e) {
        this.$message.error('Error de red');
      }
    },
    async onDelete(row) {
      this.$confirm('¿Está seguro de eliminar este pago?', 'Confirmar', {
        confirmButtonText: 'Sí',
        cancelButtonText: 'No',
        type: 'warning'
      }).then(async () => {
        try {
          const res = await this.$axios.post('/api/execute', {
            action: 'deletePago',
            params: { id_pago_local: row.id_pago_local }
          });
          if (res.data.success) {
            this.$message.success('Pago eliminado');
            this.onBuscar();
          } else {
            this.$message.error(res.data.message || 'Error al eliminar pago');
          }
        } catch (e) {
          this.$message.error('Error de red');
        }
      });
    }
  }
}
</script>


<style scoped>
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>

<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Cons Captura Energia</h1>
        <p>Mercados - Gestión de Energía</p>
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
      <div class="cons-captura-energia">
          <div class="breadcrumb">
            <router-link to="/">Inicio</router-link> /
            <span>Consulta de Pagos Capturados de Energía Eléctrica</span>
          </div>
          <h1>Detalle de los Pagos Capturados</h1>
          <div class="actions">
            <button @click="fetchPagos">Actualizar</button>
          </div>
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr class="row-hover">
                <th>Control</th>
                <th>Datos del Local</th>
                <th>Año</th>
                <th>Mes</th>
                <th>Cuota</th>
                <th>Cantidad</th>
                <th>Fecha</th>
                <th>Rec</th>
                <th>Caja</th>
                <th>Oper</th>
                <th>Importe</th>
                <th>Folio</th>
                <th>Actualización</th>
                <th>Usuario</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="pago in pagos" :key="pago.id_pago_energia" class="row-hover">
                <td>{{ pago.id_energia }}</td>
                <td>{{ pago.datoslocal }}</td>
                <td>{{ pago.axo }}</td>
                <td>{{ pago.periodo }}</td>
                <td>{{ pago.cve_consumo }}</td>
                <td>{{ pago.cantidad }}</td>
                <td>{{ pago.fecha_pago }}</td>
                <td>{{ pago.oficina_pago }}</td>
                <td>{{ pago.caja_pago }}</td>
                <td>{{ pago.operacion_pago }}</td>
                <td>{{ pago.importe_pago }}</td>
                <td>{{ pago.folio }}</td>
                <td>{{ pago.fecha_modificacion }}</td>
                <td>{{ pago.usuario }}</td>
                <td>
                  <button @click="borrarPago(pago)">Borrar</button>
                </td>
              </tr>
            </tbody>
          </table>
          <div v-if="error" class="error">{{ error }}</div>
          <div class="footer">
            <button @click="$router.back()">Salir</button>
          </div>
        </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'ConsCapturaEnergia'"
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
  name: 'ConsCapturaEnergia',
  data() {
    return {
      pagos: [],
      error: '',
      id_energia: null, // Se puede obtener de la ruta o props
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }
    };
  },
  created() {
    // Suponiendo que el id_energia viene por query o params
    this.id_energia = this.$route.query.id_energia || this.$route.params.id_energia;
    this.fetchPagos();
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
    async fetchPagos() {
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'getPagosEnergia',
              params: { id_energia: this.id_energia }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.status === 'ok') {
          this.pagos = data.eResponse.data;
        } else {
          this.error = data.eResponse.message || 'Error al cargar pagos';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async borrarPago(pago) {
      if (!confirm('¿Está seguro de borrar este pago?')) return;
      this.error = '';
      try {
        // Primero, intentar restaurar el adeudo si corresponde
        await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'restoreAdeudoEnergia',
              params: {
                id_energia: pago.id_energia,
                axo: pago.axo,
                periodo: pago.periodo,
                cve_consumo: pago.cve_consumo,
                cantidad: pago.cantidad,
                importe: pago.importe_pago,
                usuario_id: pago.id_usuario
              }
            }
          })
        });

        // Luego, borrar el pago
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'deletePagoEnergia',
              params: {
                id_energia: pago.id_energia,
                axo: pago.axo,
                periodo: pago.periodo,
                usuario_id: pago.id_usuario
              }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.status === 'ok') {
          this.fetchPagos();
        } else {
          this.error = data.eResponse.message || 'Error al borrar pago';
        }
      } catch (e) {
        this.error = e.message;
      }
    }
  }
};
</script>


<style scoped>
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>

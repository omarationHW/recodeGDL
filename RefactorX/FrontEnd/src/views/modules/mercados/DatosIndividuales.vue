<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="info-circle" />
      </div>
      <div class="module-view-info">
        <h1>Consulta Individual de Datos Generales</h1>
        <p>Mercados - Consulta de Datos Generales del Local</p>
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
      <!-- Loading overlay -->
      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Cargando datos del local...</p>
        </div>
      </div>

      <!-- Error message -->
      <div v-else-if="error" class="municipal-card">
        <div class="municipal-card-body">
          <div class="alert alert-danger">
            <font-awesome-icon icon="exclamation-circle" />
            {{ error }}
          </div>
        </div>
      </div>

      <!-- Contenido principal -->
      <div v-else>
        <!-- Datos del Mercado -->
        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5>
              <font-awesome-icon icon="store" />
              Datos del Mercado
            </h5>
          </div>
          <div class="municipal-card-body">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Control:</label>
                <p class="form-control-static">{{ datos.id_local }}</p>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Mercado:</label>
                <p class="form-control-static">{{ mercado.descripcion }}</p>
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Nombre:</label>
                <p class="form-control-static">{{ datos.nombre }}</p>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Arrendatario:</label>
                <p class="form-control-static">{{ datos.arrendatario }}</p>
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Domicilio:</label>
                <p class="form-control-static">{{ datos.domicilio }}</p>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Sector:</label>
                <p class="form-control-static">{{ datos.sector }}</p>
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Zona:</label>
                <p class="form-control-static">{{ datos.zona }}</p>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Descripción:</label>
                <p class="form-control-static">{{ datos.descripcion_local }}</p>
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Superficie:</label>
                <p class="form-control-static">{{ datos.superficie }} m²</p>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Giro:</label>
                <p class="form-control-static">{{ datos.giro }}</p>
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Fecha Alta:</label>
                <p class="form-control-static">{{ formatDate(datos.fecha_alta) }}</p>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Fecha Baja:</label>
                <p class="form-control-static">{{ formatDate(datos.fecha_baja) }}</p>
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Vigencia:</label>
                <p class="form-control-static">
                  <span :class="datos.vigencia === 'V' ? 'badge-success' : 'badge-danger'">
                    {{ datos.vigencia === 'V' ? 'Vigente' : 'Baja' }}
                  </span>
                </p>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Usuario:</label>
                <p class="form-control-static">{{ usuario.nombre || 'N/A' }}</p>
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Renta:</label>
                <p class="form-control-static"><strong>{{ formatCurrency(cuota.renta) }}</strong></p>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Actualización:</label>
                <p class="form-control-static">{{ formatDate(datos.fecha_modificacion) }}</p>
              </div>
            </div>
            <div v-if="tianguis" class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Descuento:</label>
                <p class="form-control-static">{{ tianguis.Descuento }}</p>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Motivo Descuento:</label>
                <p class="form-control-static">{{ tianguis.MotivoDescuento }}</p>
              </div>
            </div>
          </div>
        </div>

        <!-- Adeudos -->
        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5>
              <font-awesome-icon icon="exclamation-triangle" />
              Adeudos
              <span class="badge-info" v-if="adeudos.length > 0">{{ adeudos.length }} registros</span>
            </h5>
          </div>
          <div class="municipal-card-body">
            <div class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Año</th>
                    <th>Mes</th>
                    <th>Importe</th>
                    <th>Recargos</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="a in adeudos" :key="a.axo + '-' + a.periodo" class="row-hover">
                    <td>{{ a.axo }}</td>
                    <td>{{ a.periodo }}</td>
                    <td><strong>{{ formatCurrency(a.importe) }}</strong></td>
                    <td><strong>{{ formatCurrency(a.recargos) }}</strong></td>
                  </tr>
                  <tr v-if="adeudos.length === 0">
                    <td colspan="4" class="text-center text-muted">
                      <font-awesome-icon icon="check-circle" size="2x" class="empty-icon" />
                      <p>No hay adeudos registrados</p>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- Requerimientos -->
        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5>
              <font-awesome-icon icon="file-alt" />
              Requerimientos
              <span class="badge-info" v-if="requerimientos.length > 0">{{ requerimientos.length }} registros</span>
            </h5>
          </div>
          <div class="municipal-card-body">
            <div class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Folio</th>
                    <th>Fecha Emisión</th>
                    <th>Importe Multa</th>
                    <th>Importe Gastos</th>
                    <th>Vigencia</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="r in requerimientos" :key="r.folio" class="row-hover">
                    <td><strong class="text-primary">{{ r.folio }}</strong></td>
                    <td>{{ formatDate(r.fecha_emision) }}</td>
                    <td><strong>{{ formatCurrency(r.importe_multa) }}</strong></td>
                    <td><strong>{{ formatCurrency(r.importe_gastos) }}</strong></td>
                    <td>
                      <span :class="r.vigencia === 'V' ? 'badge-success' : 'badge-danger'">
                        {{ r.vigencia === 'V' ? 'Vigente' : 'Baja' }}
                      </span>
                    </td>
                  </tr>
                  <tr v-if="requerimientos.length === 0">
                    <td colspan="5" class="text-center text-muted">
                      <font-awesome-icon icon="check-circle" size="2x" class="empty-icon" />
                      <p>No hay requerimientos registrados</p>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- Movimientos -->
        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5>
              <font-awesome-icon icon="exchange-alt" />
              Movimientos
              <span class="badge-info" v-if="movimientos.length > 0">{{ movimientos.length }} registros</span>
            </h5>
          </div>
          <div class="municipal-card-body">
            <div class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Año Memo</th>
                    <th>Número Memo</th>
                    <th>Nombre</th>
                    <th>Tipo Movimiento</th>
                    <th>Fecha</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="m in movimientos" :key="m.id_movimiento" class="row-hover">
                    <td>{{ m.axo_memo }}</td>
                    <td><strong class="text-primary">{{ m.numero_memo }}</strong></td>
                    <td>{{ m.nombre }}</td>
                    <td><span class="badge-info">{{ m.tipo_movimiento }}</span></td>
                    <td>{{ formatDate(m.fecha) }}</td>
                  </tr>
                  <tr v-if="movimientos.length === 0">
                    <td colspan="5" class="text-center text-muted">
                      <font-awesome-icon icon="info-circle" size="2x" class="empty-icon" />
                      <p>No hay movimientos registrados</p>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- Botón volver -->
        <div class="button-group">
          <button type="button" class="btn-municipal-secondary" @click="$router.go(-1)">
            <font-awesome-icon icon="arrow-left" />
            Volver
          </button>
        </div>
      </div>

      <!-- Toast Notifications -->
      <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
        <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
        <span class="toast-message">{{ toast.message }}</span>
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'DatosIndividuales'"
      :moduleName="'mercados'"
      @close="closeDocumentation"
    />
  </div>
  <!-- /module-view -->
</template>

<script>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

export default {
  name: 'DatosIndividualesPage',
  components: {
    DocumentationModal
  },
  data() {
    return {
      loading: true,
      error: '',
      datos: {},
      mercado: {},
      usuario: {},
      cuota: {},
      adeudos: [],
      requerimientos: [],
      movimientos: [],
      tianguis: null,
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }
    };
  },
  async created() {
    await this.loadData();
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
    async loadData() {
      try {
        this.loading = true;
        const id_local = this.$route.params.id_local;

        if (!id_local) {
          throw new Error('No se proporcionó el ID del local');
        }

        // 1. Datos principales
        let res = await this.api('getDatosIndividuales', { id_local });
        this.datos = res || {};

        // 2. Mercado
        if (this.datos.oficina && this.datos.num_mercado) {
          res = await this.api('getMercado', {
            oficina: this.datos.oficina,
            num_mercado: this.datos.num_mercado
          });
          this.mercado = res[0] || {};
        }

        // 3. Usuario
        if (this.datos.id_usuario) {
          res = await this.api('getUsuario', { id_usuario: this.datos.id_usuario });
          this.usuario = res[0] || {};
        }

        // 4. Cuota
        if (this.datos.categoria && this.datos.seccion && this.datos.clave_cuota) {
          res = await this.api('getCuota', {
            axo: new Date().getFullYear(),
            categoria: this.datos.categoria,
            seccion: this.datos.seccion,
            clave_cuota: this.datos.clave_cuota
          });
          this.cuota = res[0] || {};
        }

        // 5. Adeudos
        res = await this.api('getAdeudos', { id_local });
        this.adeudos = res || [];

        // 6. Requerimientos
        res = await this.api('getRequerimientos', { id_local });
        this.requerimientos = res || [];

        // 7. Movimientos
        res = await this.api('getMovimientos', { id_local });
        this.movimientos = res || [];

        // 8. Tianguis (si aplica)
        if (this.datos.num_mercado === 214 && this.datos.local) {
          res = await this.api('getTianguis', { folio: this.datos.local });
          this.tianguis = res[0] || null;
        }

        this.loading = false;
        this.showToast('success', 'Datos cargados correctamente');
      } catch (e) {
        this.error = e.message || 'Error al cargar datos';
        this.loading = false;
        this.showToast('error', this.error);
      }
    },
    async api(action, params) {
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action,
              params
            }
          })
        });
        const json = await resp.json();

        if (!json.eResponse || json.eResponse.status !== 'ok') {
          throw new Error(json.eResponse?.message || 'Error en la API');
        }

        return json.eResponse.data;
      } catch (error) {
        console.error('API Error:', error);
        throw error;
      }
    },
    formatCurrency(value) {
      if (value == null || value === '') return '$0.00';
      return '$' + parseFloat(value).toLocaleString('es-MX', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      });
    },
    formatDate(dateString) {
      if (!dateString) return 'N/A';
      try {
        const date = new Date(dateString);
        return date.toLocaleDateString('es-MX', {
          year: 'numeric',
          month: '2-digit',
          day: '2-digit'
        });
      } catch (e) {
        return 'N/A';
      }
    }
  }
};
</script>

<style scoped>
.form-control-static {
  padding: 0.5rem 0;
  margin: 0;
  min-height: 34px;
}

.empty-icon {
  opacity: 0.3;
  margin-bottom: 1rem;
}
</style>

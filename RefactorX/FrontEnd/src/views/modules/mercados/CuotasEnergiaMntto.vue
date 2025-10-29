<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="bolt" />
      </div>
      <div class="module-view-info">
        <h1>Cuotas de Energía Eléctrica</h1>
        <p>Mercados - Mantenimiento de Cuotas de Energía</p>
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
      <!-- Formulario de Captura -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="edit" />
            {{ isEdit ? 'Editar' : 'Nueva' }} Cuota de Energía Eléctrica
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="onSubmit">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label" for="control">Control</label>
                <input
                  type="text"
                  class="municipal-form-control"
                  id="control"
                  v-model="form.id_kilowhatts"
                  :readonly="isEdit"
                  placeholder="Auto-generado"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label" for="axo">Año</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  id="axo"
                  v-model.number="form.axo"
                  min="2002"
                  :max="new Date().getFullYear() + 1"
                  required
                  :readonly="isEdit"
                />
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label" for="periodo">Periodo (Mes)</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  id="periodo"
                  v-model.number="form.periodo"
                  min="1"
                  max="12"
                  required
                  :readonly="isEdit"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label" for="importe">Cuota</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  id="importe"
                  v-model.number="form.importe"
                  min="0.01"
                  step="0.01"
                  required
                  placeholder="0.00"
                />
              </div>
            </div>
            <div class="button-group">
              <button type="submit" class="btn-municipal-primary" :disabled="loading">
                <font-awesome-icon :icon="isEdit ? 'save' : 'plus'" />
                {{ isEdit ? 'Actualizar' : 'Guardar' }}
              </button>
              <button type="button" class="btn-municipal-secondary" @click="onCancel" :disabled="loading">
                <font-awesome-icon icon="times" />
                Cancelar
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Filtros de Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Año</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filter.axo"
                min="2002"
                placeholder="Todos los años"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Periodo</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filter.periodo"
                min="1"
                max="12"
                placeholder="Todos los periodos"
              />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="fetchCuotas" :disabled="loading">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button class="btn-municipal-secondary" @click="clearFilters" :disabled="loading">
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
            <button class="btn-municipal-secondary" @click="fetchCuotas" :disabled="loading">
              <font-awesome-icon icon="sync-alt" />
              Actualizar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de Resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Resultados de Búsqueda
            <span class="badge-info" v-if="cuotas.length > 0">{{ cuotas.length }} registros</span>
          </h5>
          <div v-if="loading" class="spinner-border" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>

        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Control</th>
                  <th>Año</th>
                  <th>Periodo</th>
                  <th>Cuota</th>
                  <th>Fecha Alta</th>
                  <th>Usuario</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="cuota in cuotas" :key="cuota.id_kilowhatts" class="row-hover">
                  <td><strong class="text-primary">{{ cuota.id_kilowhatts }}</strong></td>
                  <td>{{ cuota.axo }}</td>
                  <td>
                    <span class="badge-info">
                      <font-awesome-icon icon="calendar" />
                      {{ cuota.periodo }}
                    </span>
                  </td>
                  <td><strong>{{ formatCurrency(cuota.importe) }}</strong></td>
                  <td>
                    <small class="text-muted">
                      <font-awesome-icon icon="calendar" />
                      {{ formatDate(cuota.fecha_alta) }}
                    </small>
                  </td>
                  <td>{{ cuota.usuario || 'N/A' }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click="editCuota(cuota)"
                        title="Editar"
                        :disabled="loading"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                    </div>
                  </td>
                </tr>
                <tr v-if="cuotas.length === 0 && !loading">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>No se encontraron cuotas con los criterios especificados</p>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Loading overlay -->
      <div v-if="loading && cuotas.length === 0" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Cargando cuotas de energía...</p>
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
      :componentName="'CuotasEnergiaMntto'"
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
  name: 'CuotasEnergiaMntto',
  data() {
    return {
      form: {
        id_kilowhatts: '',
        axo: new Date().getFullYear(),
        periodo: 1,
        importe: '',
        id_usuario: 1 // Simulación, debe venir del login
      },
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      },
      loading: false,
      isEdit: false,
      cuotas: [],
      filter: {
        axo: '',
        periodo: ''
      }
    };
  },
  mounted() {
    this.fetchCuotas();
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
    async fetchCuotas() {
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'getCuotasEnergia',
              params: {
                axo: this.filter.axo || null,
                periodo: this.filter.periodo || null
              }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse && data.eResponse.status === 'ok') {
          this.cuotas = data.eResponse.data || [];
          this.showToast('success', `${this.cuotas.length} cuotas cargadas`);
        } else {
          this.cuotas = [];
          this.showToast('warning', data.eResponse?.message || 'No se encontraron registros');
        }
      } catch (e) {
        this.cuotas = [];
        this.showToast('error', 'Error al cargar cuotas: ' + e.message);
      } finally {
        this.loading = false;
      }
    },
    clearFilters() {
      this.filter = {
        axo: '',
        periodo: ''
      };
      this.fetchCuotas();
    },
    async onSubmit() {
      if (!this.form.importe || this.form.importe <= 0) {
        this.showToast('warning', 'La cuota debe ser mayor a cero');
        return;
      }

      this.loading = true;
      const action = this.isEdit ? 'updateCuotaEnergia' : 'insertCuotaEnergia';

      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action,
              params: { ...this.form }
            }
          })
        });
        const data = await res.json();

        if (data.eResponse && data.eResponse.status === 'ok') {
          this.showToast('success', this.isEdit ? 'Cuota actualizada exitosamente' : 'Cuota guardada exitosamente');
          await this.fetchCuotas();
          this.onCancel();
        } else {
          this.showToast('error', data.eResponse?.message || 'Error al guardar la cuota');
        }
      } catch (e) {
        this.showToast('error', 'Error al guardar: ' + e.message);
      } finally {
        this.loading = false;
      }
    },
    editCuota(cuota) {
      this.form = {
        id_kilowhatts: cuota.id_kilowhatts,
        axo: cuota.axo,
        periodo: cuota.periodo,
        importe: cuota.importe,
        id_usuario: 1 // Simulación
      };
      this.isEdit = true;
      window.scrollTo({ top: 0, behavior: 'smooth' });
    },
    onCancel() {
      this.form = {
        id_kilowhatts: '',
        axo: new Date().getFullYear(),
        periodo: 1,
        importe: '',
        id_usuario: 1
      };
      this.isEdit = false;
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
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>

<template>
  <div class="carga-cartera-page">
    <h1>Carga de Carteras</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Carga de Carteras</li>
      </ol>
    </nav>
    <div class="form-section">
      <div class="row mb-3">
        <div class="col-md-6">
          <label for="tablaSelect"><strong>Tabla a Cargar Cartera</strong></label>
          <select v-model="selectedTabla" @change="onTablaChange" class="form-control" id="tablaSelect">
            <option v-for="tabla in tablas" :key="tabla.cve_tab" :value="tabla.cve_tab">
              {{ tabla.cve_tab }} - {{ tabla.nombre }}
            </option>
          </select>
        </div>
        <div class="col-md-3">
          <label for="ejercicioSelect"><strong>Ejercicio</strong></label>
          <select v-model="selectedEjercicio" @change="onEjercicioChange" class="form-control" id="ejercicioSelect">
            <option v-for="ej in ejercicios" :key="ej.ejercicio" :value="ej.ejercicio">
              {{ ej.ejercicio }}
            </option>
          </select>
        </div>
      </div>
      <div class="row mb-3">
        <div class="col-12">
          <table class="table table-bordered table-sm">
            <thead>
              <tr>
                <th>Ejercicio</th>
                <th>Cve Unidad</th>
                <th>Cve Operatividad</th>
                <th>Descripción</th>
                <th>Costo</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="unidad in unidades" :key="unidad.cve_unidad + '-' + unidad.cve_operatividad">
                <td>{{ unidad.ejercicio }}</td>
                <td>{{ unidad.cve_unidad }}</td>
                <td>{{ unidad.cve_operatividad }}</td>
                <td>{{ unidad.descripcion }}</td>
                <td>{{ unidad.costo }}</td>
              </tr>
              <tr v-if="unidades.length === 0">
                <td colspan="5" class="text-center">No hay unidades para este ejercicio</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="row mb-3">
        <div class="col-md-6">
          <button class="btn btn-primary" :disabled="!canApply" @click="onAplica">Aplicar</button>
          <button class="btn btn-secondary ml-2" @click="onSalir">Salir</button>
        </div>
      </div>
      <div v-if="message" class="alert" :class="{'alert-success': success, 'alert-danger': !success}">
        {{ message }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CargaCarteraPage',
  data() {
    return {
      tablas: [],
      ejercicios: [],
      unidades: [],
      selectedTabla: '',
      selectedEjercicio: '',
      message: '',
      success: false,
      loading: false
    };
  },
  computed: {
    canApply() {
      return this.selectedTabla && this.selectedEjercicio && this.unidades.length > 0;
    }
  },
  methods: {
    async fetchTablas() {
      const res = await this.apiRequest('getTablas');
      if (res.success) {
        this.tablas = res.data;
        if (this.tablas.length > 0) {
          this.selectedTabla = this.tablas[0].cve_tab;
          await this.onTablaChange();
        }
      }
    },
    async onTablaChange() {
      if (!this.selectedTabla) return;
      const res = await this.apiRequest('getEjercicios', { cve_tab: this.selectedTabla });
      if (res.success) {
        this.ejercicios = res.data;
        if (this.ejercicios.length > 0) {
          this.selectedEjercicio = this.ejercicios[0].ejercicio;
          await this.onEjercicioChange();
        } else {
          this.selectedEjercicio = '';
          this.unidades = [];
        }
      }
    },
    async onEjercicioChange() {
      if (!this.selectedTabla || !this.selectedEjercicio) return;
      const res = await this.apiRequest('getUnidades', {
        cve_tab: this.selectedTabla,
        ejer: this.selectedEjercicio
      });
      if (res.success) {
        this.unidades = res.data;
      } else {
        this.unidades = [];
      }
    },
    async onAplica() {
      if (!confirm('¿Deseas GENERAR LA CARTERA para la tabla seleccionada y ejercicio?')) return;
      this.loading = true;
      this.message = '';
      this.success = false;
      try {
        const res = await this.apiRequest('cargaCartera', {
          cve_tab: this.selectedTabla,
          ejer: this.selectedEjercicio
        });
        if (res.success && res.data && res.data.length > 0) {
          const result = res.data[0];
          if (result.status === 0) {
            this.message = result.concepto_status || 'Cartera generada correctamente';
            this.success = true;
          } else {
            this.message = result.concepto_status || 'Error al generar cartera';
            this.success = false;
          }
        } else {
          this.message = res.message || 'Error inesperado en la operación';
          this.success = false;
        }
      } catch (e) {
        this.message = 'Error de comunicación con el servidor';
        this.success = false;
      }
      this.loading = false;
    },
    onSalir() {
      this.$router.push('/');
    },
    async apiRequest(action, params = {}) {
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              action,
              params
            }
          })
        });
        const data = await response.json();
        return data.eResponse || { success: false, message: 'Respuesta inválida' };
      } catch (e) {
        return { success: false, message: 'Error de red' };
      }
    }
  },
  async mounted() {
    await this.fetchTablas();
  }
};
</script>

<style scoped>
.carga-cartera-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.form-section {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>

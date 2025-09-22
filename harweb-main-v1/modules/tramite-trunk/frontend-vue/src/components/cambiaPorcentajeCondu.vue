<template>
  <div class="cambia-porcentaje-condu-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Cambio de Porcentajes de Condueños</li>
      </ol>
    </nav>
    <h2>Cambio de Porcentajes de Condueños</h2>
    <div v-if="loading" class="alert alert-info">Cargando información...</div>
    <div v-else>
      <form @submit.prevent="onSubmit">
        <table class="table table-bordered table-sm">
          <thead>
            <tr>
              <th>Clave</th>
              <th>Nombre</th>
              <th>Encabeza</th>
              <th>Porcentaje</th>
              <th>Calidad</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(prop, idx) in propietarios" :key="prop.cvecont">
              <td>{{ prop.cvecont }}</td>
              <td>{{ prop.nombre_completo }}</td>
              <td>
                <select v-model="prop.encabeza" class="form-control form-control-sm">
                  <option value="S">S</option>
                  <option value="N">N</option>
                </select>
              </td>
              <td>
                <input type="number" step="0.01" min="0" max="100" v-model.number="prop.porcentaje" class="form-control form-control-sm" />
              </td>
              <td>
                <select v-model="prop.descripcion" class="form-control form-control-sm">
                  <option v-for="cal in calidades" :key="cal.descripcion" :value="cal.descripcion">{{ cal.descripcion }}</option>
                </select>
              </td>
            </tr>
          </tbody>
        </table>
        <div class="row mb-2">
          <div class="col-md-6">
            <strong>Total porcentaje:</strong>
            <span :class="{'text-danger': totalPorcentaje !== 100, 'text-success': totalPorcentaje === 100}">{{ totalPorcentaje.toFixed(2) }}%</span>
          </div>
        </div>
        <div class="form-group">
          <label for="observacion">Observación</label>
          <textarea id="observacion" v-model="observacion" class="form-control" rows="2"></textarea>
        </div>
        <div class="form-group mt-3">
          <button type="submit" class="btn btn-primary" :disabled="saving">Actualizar</button>
          <button type="button" class="btn btn-secondary ml-2" @click="onCancel">Cancelar</button>
        </div>
        <div v-if="error" class="alert alert-danger mt-2">{{ error }}</div>
        <div v-if="success" class="alert alert-success mt-2">{{ success }}</div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CambiaPorcentajeConduPage',
  data() {
    return {
      propietarios: [],
      calidades: [],
      loading: true,
      saving: false,
      error: '',
      success: '',
      observacion: '',
      cvecuenta: null,
      cveregprop: null
    };
  },
  computed: {
    totalPorcentaje() {
      return this.propietarios.reduce((sum, p) => sum + (parseFloat(p.porcentaje) || 0), 0);
    }
  },
  methods: {
    async fetchData() {
      this.loading = true;
      this.error = '';
      try {
        // Suponiendo que cvecuenta y cveregprop vienen por query o props
        this.cvecuenta = this.$route.query.cvecuenta || 0;
        this.cveregprop = this.$route.query.cveregprop || 0;
        // 1. Propietarios
        let resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getPropietarios',
            params: { cvecuenta: this.cvecuenta, cveregprop: this.cveregprop }
          }
        });
        this.propietarios = resp.data.data.map(p => ({ ...p }));
        // 2. Calidades
        let resp2 = await this.$axios.post('/api/execute', {
          eRequest: { action: 'getCalidades', params: {} }
        });
        this.calidades = resp2.data.data;
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      } finally {
        this.loading = false;
      }
    },
    async onSubmit() {
      this.error = '';
      this.success = '';
      // Validaciones
      if (this.totalPorcentaje !== 100) {
        this.error = 'El total de porcentaje debe ser exactamente 100%.';
        return;
      }
      const encabezan = this.propietarios.filter(p => p.encabeza === 'S');
      if (encabezan.length !== 1) {
        this.error = 'Debe haber exactamente un contribuyente que encabece.';
        return;
      }
      const propietarios = this.propietarios.map(p => ({
        cvecont: p.cvecont,
        porcentaje: p.porcentaje,
        encabeza: p.encabeza,
        descripcion: p.descripcion
      }));
      this.saving = true;
      try {
        let resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'updatePorcentajes',
            params: {
              cvecuenta: this.cvecuenta,
              cveregprop: this.cveregprop,
              propietarios,
              observacion: this.observacion
            }
          }
        });
        if (resp.data.success) {
          this.success = 'Porcentajes actualizados correctamente.';
          await this.fetchData();
        } else {
          this.error = resp.data.message || 'Error al actualizar.';
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      } finally {
        this.saving = false;
      }
    },
    onCancel() {
      this.$router.back();
    }
  },
  mounted() {
    this.fetchData();
  }
};
</script>

<style scoped>
.cambia-porcentaje-condu-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
.table-sm th, .table-sm td {
  padding: 0.3rem 0.5rem;
}
</style>

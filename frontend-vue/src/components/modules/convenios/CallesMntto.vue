<template>
  <div class="calles-mntto-page">
    <h1>Mantenimiento de Calles</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Calles</li>
      </ol>
    </nav>
    <form @submit.prevent="onSubmit">
      <div class="form-row">
        <label>Colonia</label>
        <select v-model="form.colonia" required>
          <option value="">Seleccione...</option>
          <option v-for="col in catalogs.colonias" :key="col.colonia" :value="col.colonia">
            {{ col.colonia }} - {{ col.descripcion }}
          </option>
        </select>
      </div>
      <div class="form-row">
        <label>Calle</label>
        <input v-model.number="form.calle" type="number" min="1" max="999" required />
      </div>
      <div class="form-row">
        <label>Tipo</label>
        <select v-model="form.tipo" required>
          <option value="">Seleccione...</option>
          <option v-for="tipo in catalogs.tipos" :key="tipo.tipo" :value="tipo.tipo">
            {{ tipo.tipo }} - {{ tipo.descripcion }}
          </option>
        </select>
      </div>
      <div class="form-row">
        <label>Servicio</label>
        <select v-model="form.servicio" required>
          <option value="">Seleccione...</option>
          <option v-for="srv in catalogs.servicios" :key="srv.servicio" :value="srv.servicio">
            {{ srv.servicio }} - {{ srv.descripcion }}
          </option>
        </select>
      </div>
      <div class="form-row">
        <label>Desc. Calle</label>
        <input v-model="form.desc_calle" maxlength="50" required />
      </div>
      <div class="form-row">
        <label>Año de Obra</label>
        <input v-model.number="form.axo_obra" type="number" min="1990" max="2999" required />
      </div>
      <div class="form-row">
        <label>Cuenta Ingreso</label>
        <select v-model="form.cuenta_ingreso" required>
          <option value="">Seleccione...</option>
          <option v-for="cta in catalogs.cuentas" :key="cta.cta_aplicacion" :value="cta.cta_aplicacion">
            {{ cta.cta_aplicacion }} - {{ cta.descripcion }}
          </option>
        </select>
      </div>
      <div class="form-row">
        <label>Cuenta Rezago</label>
        <select v-model="form.cuenta_rezago" required>
          <option value="">Seleccione...</option>
          <option v-for="cta in catalogs.cuentas" :key="cta.cta_aplicacion" :value="cta.cta_aplicacion">
            {{ cta.cta_aplicacion }} - {{ cta.descripcion }}
          </option>
        </select>
      </div>
      <div class="form-row">
        <label>Vigencia</label>
        <select v-model="form.vigencia_obra" required>
          <option value="A">VIGENTE</option>
          <option value="C">CANCELADA</option>
        </select>
      </div>
      <div class="form-row">
        <label>Plazo</label>
        <input v-model.number="form.plazo" type="number" min="1" max="99" required />
      </div>
      <div class="form-row">
        <label>Tipo de Plazo</label>
        <select v-model="form.clave_plazo" required>
          <option value="S">SEMANAL</option>
          <option value="Q">QUINCENAL</option>
          <option value="M">MENSUAL</option>
        </select>
      </div>
      <div class="form-actions">
        <button type="submit" class="btn btn-primary">{{ isEdit ? 'Actualizar' : 'Agregar' }}</button>
        <button type="button" class="btn btn-secondary" @click="onReset">Cancelar</button>
      </div>
    </form>
    <div class="mt-4">
      <h2>Calles Existentes</h2>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>Colonia</th>
            <th>Calle</th>
            <th>Tipo</th>
            <th>Servicio</th>
            <th>Desc. Calle</th>
            <th>Año Obra</th>
            <th>Cuenta Ing.</th>
            <th>Vigencia</th>
            <th>Plazo</th>
            <th>Tipo Plazo</th>
            <th>Cuenta Rezago</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in calles" :key="row.colonia + '-' + row.calle">
            <td>{{ row.colonia }}</td>
            <td>{{ row.calle }}</td>
            <td>{{ row.tipo }}</td>
            <td>{{ row.servicio }}</td>
            <td>{{ row.desc_calle }}</td>
            <td>{{ row.axo_obra }}</td>
            <td>{{ row.cuenta_ingreso }}</td>
            <td>{{ row.vigencia_obra }}</td>
            <td>{{ row.plazo }}</td>
            <td>{{ row.clave_plazo }}</td>
            <td>{{ row.cuenta_rezago }}</td>
            <td>
              <button @click="onEdit(row)" class="btn btn-sm btn-info">Editar</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="message" class="alert" :class="{'alert-success': success, 'alert-danger': !success}">{{ message }}</div>
  </div>
</template>

<script>
export default {
  name: 'CallesMnttoPage',
  data() {
    return {
      catalogs: {
        colonias: [],
        tipos: [],
        servicios: [],
        cuentas: []
      },
      calles: [],
      form: {
        colonia: '',
        calle: '',
        tipo: '',
        servicio: '',
        desc_calle: '',
        axo_obra: new Date().getFullYear(),
        cuenta_ingreso: '',
        cuenta_rezago: '',
        vigencia_obra: 'A',
        plazo: '',
        clave_plazo: 'M'
      },
      isEdit: false,
      message: '',
      success: true
    };
  },
  created() {
    this.loadCatalogs();
    this.loadCalles();
  },
  methods: {
    async loadCatalogs() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'convenios.getCatalogs',
          payload: {}
        });
        if (res.data.status === 'success') {
          this.catalogs = res.data.data;
        }
      } catch (error) {
        console.error('Error loading catalogs:', error);
      }
    },
    async loadCalles() {
      // Para demo, cargar todas las calles de la colonia 1 y calle 1
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'convenios.getCalle',
          payload: { colonia: 1, calle: 1 }
        });
        if (res.data.status === 'success') {
          this.calles = res.data.data;
        }
      } catch (error) {
        console.error('Error loading calles:', error);
      }
    },
    async onSubmit() {
      const action = this.isEdit ? 'updateCalle' : 'insertCalle';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: `convenios.${action}`,
          payload: this.form
        });
        if (res.data.status === 'success') {
          this.message = res.data.message;
          this.success = true;
          this.onReset();
          this.loadCalles();
        } else {
          this.message = res.data.message;
          this.success = false;
        }
      } catch (error) {
        this.message = 'Error de conexión con el servidor';
        this.success = false;
      }
    },
    onEdit(row) {
      this.form = { ...row };
      this.isEdit = true;
      this.message = '';
    },
    onReset() {
      this.form = {
        colonia: '',
        calle: '',
        tipo: '',
        servicio: '',
        desc_calle: '',
        axo_obra: new Date().getFullYear(),
        cuenta_ingreso: '',
        cuenta_rezago: '',
        vigencia_obra: 'A',
        plazo: '',
        clave_plazo: 'M'
      };
      this.isEdit = false;
      this.message = '';
    }
  }
};
</script>

<style scoped>
.calles-mntto-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  flex-direction: column;
}
.form-actions {
  margin-top: 1.5rem;
}
.table {
  width: 100%;
  margin-top: 1rem;
}
.alert {
  margin-top: 1rem;
}
</style>

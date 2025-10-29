<template>
  <div class="gadeudos-opcmult-ra">
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Re-activación de Adeudos</span>
    </div>
    <div class="panel panel-top">
      <h2>{{ nombreTabla ? 'RE-ACTIVACION DE ADEUDOS EN : ' + nombreTabla : 'Cargando...' }}</h2>
      <div class="form-row">
        <label>Selecciona la búsqueda</label>
        <div v-if="isLocal">
          <input v-model="localNum" placeholder="Número de Local" @keyup.enter="onBuscar" />
          <input v-model="letra" placeholder="Letra" @keyup.enter="onBuscar" />
        </div>
        <div v-else>
          <input v-model="numExpN" placeholder="Número de Expediente" @keypress="onlyNumber" @keyup.enter="onBuscar" />
        </div>
        <button @click="onBuscar">Buscar</button>
        <button @click="onSalir">Salir</button>
      </div>
    </div>
    <div v-if="showDatos" class="panel panel-datos">
      <div class="datos-grid">
        <div><strong>Status:</strong> <span>{{ datos.statusregistro }}</span></div>
        <div><strong>Concesionario:</strong> <span>{{ datos.concesionario }}</span></div>
        <div><strong>Ubicación:</strong> <span>{{ datos.ubicacion }}</span></div>
        <div><strong>Nombre Comercial:</strong> <span>{{ datos.nomcomercial }}</span></div>
        <div><strong>Lugar:</strong> <span>{{ datos.lugar }}</span></div>
        <div><strong>Observaciones:</strong> <span>{{ datos.obs }}</span></div>
        <div><strong>Tipo:</strong> <span>{{ datos.unidades }}</span></div>
        <div><strong>Inicio oblig.:</strong> <span>{{ formatDate(datos.fechainicio) }}</span></div>
        <div><strong>Fin oblig.:</strong> <span>{{ formatDate(datos.fechafin) }}</span></div>
        <div><strong>No. Licencia:</strong> <span>{{ datos.licencia }}</span></div>
        <div><strong>Superficie Mts.2:</strong> <span>{{ datos.superficie }}</span></div>
        <div><strong>Sector:</strong> <span>{{ datos.sector }}</span></div>
        <div><strong>Recaudadora:</strong> <span>{{ datos.recaudadora }}</span></div>
        <div><strong>Zona:</strong> <span>{{ datos.zona }}</span></div>
      </div>
      <div class="form-row">
        <label>Opción a realizar</label>
        <select v-model="opcion">
          <option value="P">P - RE-ACTIVACION DE REGISTRO</option>
        </select>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'GAdeudosOpcMultRA',
  data() {
    return {
      glo_Tabla: 3, // Por ejemplo, puede venir de ruta o props
      nombreTabla: '',
      descripcionTabla: '',
      etiq: {},
      numExpN: '',
      letra: '',
      localNum: '',
      datos: {},
      showDatos: false,
      opcion: 'P',
      error: '',
      isLocal: false // Determina si es búsqueda por local o expediente
    };
  },
  mounted() {
    this.cargarEtiquetas();
    this.cargarTabla();
    this.isLocal = (this.glo_Tabla === 3);
  },
  methods: {
    async cargarTabla() {
      try {
        const res = await this.api('get_tabla_info', { par_tab: this.glo_Tabla });
        if (res && res.length > 0) {
          this.nombreTabla = res[0].nombre;
          this.descripcionTabla = res[0].descripcion;
        }
      } catch (e) {
        this.error = 'Error al cargar tabla';
      }
    },
    async cargarEtiquetas() {
      try {
        const res = await this.api('get_etiq', { par_tab: this.glo_Tabla });
        if (res && res.length > 0) {
          this.etiq = res[0];
        }
      } catch (e) {
        this.error = 'Error al cargar etiquetas';
      }
    },
    async onBuscar() {
      this.error = '';
      let par_control = '';
      if (this.isLocal) {
        if (!this.localNum || this.localNum === '0') {
          this.error = 'Falta el dato del NUMERO DE LOCAL, intentalo de nuevo';
          return;
        }
        par_control = this.localNum + (this.letra ? '-' + this.letra : '');
      } else {
        if (!this.numExpN || this.numExpN === '0') {
          this.error = 'Falta el dato del NUMERO DE EXPEDIENTE, intentalo de nuevo';
          return;
        }
        par_control = (this.etiq.abreviatura || '') + this.numExpN;
      }
      try {
        const res = await this.api('get_datos_concesion', {
          par_tab: this.glo_Tabla,
          par_control
        });
        if (res && res.length > 0 && res[0].status !== -1) {
          this.datos = res[0];
          this.showDatos = true;
        } else {
          this.showDatos = false;
          this.error = 'No existe REGISTRO ALGUNO con este dato, intentalo de nuevo';
        }
      } catch (e) {
        this.error = 'Error al buscar datos';
      }
    },
    onSalir() {
      this.$router.push('/');
    },
    onlyNumber(e) {
      if (!/[0-9]/.test(e.key)) {
        e.preventDefault();
      }
    },
    formatDate(date) {
      if (!date) return '';
      const d = new Date(date);
      if (isNaN(d)) return date;
      return d.toLocaleDateString();
    },
    async api(eRequest, params = {}) {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({ eRequest, params })
      });
      const json = await res.json();
      if (json.eResponse && json.eResponse.success) {
        return json.eResponse.data;
      } else {
        throw new Error(json.eResponse ? json.eResponse.message : 'Error API');
      }
    }
  }
};
</script>

<style scoped>
.gadeudos-opcmult-ra {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
  color: #888;
}
.panel {
  background: #f9f9f9;
  border: 1px solid #ddd;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  border-radius: 6px;
}
.form-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}
.form-row label {
  min-width: 180px;
  font-weight: bold;
}
.datos-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.5rem 2rem;
  margin-bottom: 1.5rem;
}
.alert {
  color: #a94442;
  background: #f2dede;
  border: 1px solid #ebccd1;
  padding: 1rem;
  border-radius: 4px;
}
button {
  background: #0056b3;
  color: #fff;
  border: none;
  padding: 0.5rem 1.2rem;
  border-radius: 4px;
  cursor: pointer;
}
button + button {
  background: #888;
}
select, input {
  padding: 0.3rem 0.7rem;
  border: 1px solid #bbb;
  border-radius: 3px;
}
</style>

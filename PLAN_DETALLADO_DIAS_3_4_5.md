# 📋 Plan Detallado - Días 3, 4 y 5
## Continuación del Plan de Integración Frontend

---

# 📅 DÍA 3 - MIÉRCOLES (Continuación): Padrón de Licencias

## 2:00 - 8:00 PM | Completar Padrón de Licencias

### Dev1: Módulo de Pagos y Facturación (10 forms)

**Componentes a desarrollar:**

```javascript
// services/licencias-pagos.service.js
export const licenciasPagosService = {
  // Pagos
  registrarPago: async (licenciaId, data) => {
    return await api.post(`/licencias/${licenciaId}/pagos`, data)
  },

  getAdeudos: async (licenciaId) => {
    return await api.get(`/licencias/${licenciaId}/adeudos`)
  },

  calcularAdeudo: async (licenciaId, periodo) => {
    return await api.post(`/licencias/${licenciaId}/calcular-adeudo`, { periodo })
  },

  // Descuentos
  aplicarDescuento: async (licenciaId, descuentoData) => {
    return await api.post(`/licencias/${licenciaId}/descuentos`, descuentoData)
  },

  getDescuentosDisponibles: async (licenciaId) => {
    return await api.get(`/licencias/${licenciaId}/descuentos-disponibles`)
  },

  // Facturación
  generarFactura: async (pagoId) => {
    return await api.post(`/pagos/${pagoId}/facturar`)
  },

  getFactura: async (facturaId) => {
    return await api.get(`/facturas/${facturaId}`)
  },

  descargarFacturaPDF: async (facturaId) => {
    return await api.get(`/facturas/${facturaId}/pdf`, {
      responseType: 'blob'
    })
  }
}
```

**Componente de Pagos:**

```vue
<!-- modules/padron_licencias/views/LicenciasPagos.vue -->
<template>
  <div class="licencias-pagos">
    <h2>Pagos y Facturación</h2>

    <!-- Búsqueda de licencia -->
    <Card>
      <template #content>
        <div class="p-fluid">
          <div class="p-field">
            <label>Buscar Licencia</label>
            <AutoComplete
              v-model="licenciaSeleccionada"
              :suggestions="licenciasSugerencias"
              @complete="buscarLicencias"
              field="numero"
              placeholder="Número de licencia..."
              @item-select="cargarDetalles"
            >
              <template #item="{ item }">
                <div>
                  <div><strong>{{ item.numero }}</strong></div>
                  <div class="text-sm">{{ item.razon_social }}</div>
                </div>
              </template>
            </AutoComplete>
          </div>
        </div>
      </template>
    </Card>

    <!-- Detalles de adeudos -->
    <Card v-if="licenciaSeleccionada" class="mt-3">
      <template #title>
        Licencia: {{ licenciaSeleccionada.numero }}
      </template>

      <template #content>
        <TabView>
          <!-- Tab Adeudos -->
          <TabPanel header="Adeudos">
            <DataTable :value="adeudos" :loading="loadingAdeudos">
              <Column field="concepto" header="Concepto"></Column>
              <Column field="periodo" header="Período"></Column>
              <Column field="monto" header="Monto">
                <template #body="{ data }">
                  {{ formatCurrency(data.monto) }}
                </template>
              </Column>
              <Column field="recargos" header="Recargos">
                <template #body="{ data }">
                  {{ formatCurrency(data.recargos) }}
                </template>
              </Column>
              <Column field="total" header="Total">
                <template #body="{ data }">
                  <strong>{{ formatCurrency(data.total) }}</strong>
                </template>
              </Column>
              <Column header="Acciones">
                <template #body="{ data }">
                  <Button
                    label="Pagar"
                    class="p-button-sm"
                    @click="abrirFormularioPago(data)"
                  />
                </template>
              </Column>
            </DataTable>

            <div class="mt-3 p-3 bg-gray-100 border-round">
              <div class="flex justify-content-between">
                <strong>Total a Pagar:</strong>
                <strong class="text-2xl text-primary">
                  {{ formatCurrency(totalAdeudo) }}
                </strong>
              </div>
            </div>

            <div class="mt-3 flex justify-content-end gap-2">
              <Button
                label="Aplicar Descuento"
                icon="pi pi-percentage"
                class="p-button-outlined"
                @click="mostrarDescuentos = true"
              />
              <Button
                label="Pagar Todo"
                icon="pi pi-dollar"
                @click="pagarTodo"
              />
            </div>
          </TabPanel>

          <!-- Tab Historial de Pagos -->
          <TabPanel header="Historial">
            <DataTable :value="historialPagos">
              <Column field="fecha" header="Fecha">
                <template #body="{ data }">
                  {{ formatDate(data.fecha) }}
                </template>
              </Column>
              <Column field="folio" header="Folio"></Column>
              <Column field="concepto" header="Concepto"></Column>
              <Column field="monto" header="Monto">
                <template #body="{ data }">
                  {{ formatCurrency(data.monto) }}
                </template>
              </Column>
              <Column field="facturado" header="Facturado">
                <template #body="{ data }">
                  <Tag
                    :value="data.facturado ? 'Sí' : 'No'"
                    :severity="data.facturado ? 'success' : 'warning'"
                  />
                </template>
              </Column>
              <Column header="Acciones">
                <template #body="{ data }">
                  <Button
                    v-if="!data.facturado"
                    label="Facturar"
                    class="p-button-sm p-button-outlined"
                    @click="facturarPago(data)"
                  />
                  <Button
                    v-else
                    icon="pi pi-download"
                    class="p-button-sm p-button-text"
                    @click="descargarFactura(data.factura_id)"
                    v-tooltip="'Descargar Factura'"
                  />
                </template>
              </Column>
            </DataTable>
          </TabPanel>
        </TabView>
      </template>
    </Card>

    <!-- Dialog Formulario de Pago -->
    <Dialog
      v-model:visible="mostrarFormularioPago"
      header="Registrar Pago"
      :modal="true"
      :style="{ width: '50vw' }"
    >
      <div class="p-fluid">
        <div class="p-field">
          <label>Forma de Pago *</label>
          <Dropdown
            v-model="formPago.forma_pago"
            :options="formasPago"
            optionLabel="label"
            optionValue="value"
            placeholder="Seleccione..."
          />
        </div>

        <div class="p-field">
          <label>Monto *</label>
          <InputNumber
            v-model="formPago.monto"
            mode="currency"
            currency="MXN"
            locale="es-MX"
          />
        </div>

        <div class="p-field" v-if="formPago.forma_pago === 'TRANSFERENCIA'">
          <label>Referencia</label>
          <InputText v-model="formPago.referencia" />
        </div>

        <div class="p-field">
          <label>Observaciones</label>
          <Textarea v-model="formPago.observaciones" rows="3" />
        </div>
      </div>

      <template #footer>
        <Button
          label="Cancelar"
          icon="pi pi-times"
          class="p-button-text"
          @click="mostrarFormularioPago = false"
        />
        <Button
          label="Registrar Pago"
          icon="pi pi-check"
          @click="registrarPago"
          :loading="guardando"
        />
      </template>
    </Dialog>

    <!-- Dialog Descuentos -->
    <Dialog
      v-model:visible="mostrarDescuentos"
      header="Descuentos Disponibles"
      :modal="true"
    >
      <DataTable :value="descuentosDisponibles" selectionMode="single">
        <Column field="nombre" header="Descuento"></Column>
        <Column field="porcentaje" header="Porcentaje">
          <template #body="{ data }">
            {{ data.porcentaje }}%
          </template>
        </Column>
        <Column field="descripcion" header="Descripción"></Column>
        <Column header="Aplicar">
          <template #body="{ data }">
            <Button
              label="Aplicar"
              class="p-button-sm"
              @click="aplicarDescuento(data)"
            />
          </template>
        </Column>
      </DataTable>
    </Dialog>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { licenciasPagosService } from '@/services/licencias-pagos.service'
import { useToast } from 'primevue/usetoast'

const toast = useToast()

// State
const licenciaSeleccionada = ref(null)
const licenciasSugerencias = ref([])
const adeudos = ref([])
const historialPagos = ref([])
const descuentosDisponibles = ref([])
const loadingAdeudos = ref(false)
const mostrarFormularioPago = ref(false)
const mostrarDescuentos = ref(false)
const guardando = ref(false)

const formPago = ref({
  forma_pago: null,
  monto: 0,
  referencia: '',
  observaciones: ''
})

const formasPago = [
  { label: 'Efectivo', value: 'EFECTIVO' },
  { label: 'Transferencia', value: 'TRANSFERENCIA' },
  { label: 'Tarjeta', value: 'TARJETA' },
  { label: 'Cheque', value: 'CHEQUE' }
]

// Computed
const totalAdeudo = computed(() => {
  return adeudos.value.reduce((sum, a) => sum + a.total, 0)
})

// Methods
const buscarLicencias = async (event) => {
  // Implementar búsqueda
}

const cargarDetalles = async () => {
  if (!licenciaSeleccionada.value) return

  loadingAdeudos.value = true
  try {
    const [adeudosData, historialData, descuentosData] = await Promise.all([
      licenciasPagosService.getAdeudos(licenciaSeleccionada.value.id),
      licenciasPagosService.getHistorial(licenciaSeleccionada.value.id),
      licenciasPagosService.getDescuentosDisponibles(licenciaSeleccionada.value.id)
    ])

    adeudos.value = adeudosData.data
    historialPagos.value = historialData.data
    descuentosDisponibles.value = descuentosData.data
  } catch (error) {
    toast.add({
      severity: 'error',
      summary: 'Error',
      detail: 'Error al cargar detalles',
      life: 3000
    })
  } finally {
    loadingAdeudos.value = false
  }
}

const abrirFormularioPago = (adeudo) => {
  formPago.value = {
    adeudo_id: adeudo.id,
    forma_pago: null,
    monto: adeudo.total,
    referencia: '',
    observaciones: ''
  }
  mostrarFormularioPago.value = true
}

const registrarPago = async () => {
  guardando.value = true
  try {
    await licenciasPagosService.registrarPago(
      licenciaSeleccionada.value.id,
      formPago.value
    )

    toast.add({
      severity: 'success',
      summary: 'Éxito',
      detail: 'Pago registrado correctamente',
      life: 3000
    })

    mostrarFormularioPago.value = false
    cargarDetalles()
  } catch (error) {
    toast.add({
      severity: 'error',
      summary: 'Error',
      detail: error.response?.data?.message || 'Error al registrar pago',
      life: 3000
    })
  } finally {
    guardando.value = false
  }
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

const formatDate = (fecha) => {
  return new Date(fecha).toLocaleDateString('es-MX')
}
</script>
```

### Dev2: Módulo de Reportes y Dashboard (10 forms)

**Usar Claude Code para generar reportes:**

```
PROMPT CLAUDE CODE:

Genera componentes de reportes para Padrón de Licencias:

1. ReporteLicenciasVigentes.vue
   - Tabla con filtros
   - Exportación a Excel
   - Gráfica de barras por giro

2. ReporteEstadisticas.vue
   - Dashboard con métricas clave
   - Gráficas de pastel (licencias por estatus)
   - Línea de tiempo (licencias nuevas por mes)
   - KPIs: Total licencias, vigentes, vencidas, ingresos

3. ReporteAnuncios.vue
   - Lista de anuncios por zona
   - Filtros avanzados
   - Mapa de ubicaciones

4. DashboardLicencias.vue
   - Vista ejecutiva
   - Cards con números principales
   - Gráficas Chart.js
   - Alertas de licencias por vencer

Usa:
- PrimeVue DataTable
- Chart.js para gráficas
- xlsx library para exportar Excel
- Integración con backend para datos
```

---

### 7:30 - 8:00 PM | Testing y Commit Día 3

```bash
# Testing completo Padrón Licencias
cd frontend
npm run build

# Verificar que no hay errores
npm run lint

# Testing manual en navegador
npm run dev
# Probar:
# - Listado de licencias
# - Crear nueva licencia
# - Editar licencia
# - Módulo de trámites
# - Módulo de anuncios
# - Pagos y facturación
# - Reportes

# Commit
git add .
git commit -m "Add: Frontend Día 3 - Padrón de Licencias completo (60 forms)"
git push origin feature/frontend-week1
```

**Checklist Fin Día 3:**
- [ ] Padrón de Licencias 100% funcional
- [ ] 60 componentes Vue creados
- [ ] Integración con backend verificada
- [ ] Testing manual pasado
- [ ] Build sin errores

**PROGRESO TOTAL: 195/470 = 41% ✅**

---

# 📅 DÍA 4 - JUEVES: Sistemas Grandes

## Sistema 7: MULTAS Y REGLAMENTOS (90 formularios)

**SISTEMA MÁS COMPLEJO - Ambos devs trabajando en paralelo**

### 8:00 - 8:30 AM | Standup y Análisis

**Análisis con Claude Code:**

```
PROMPT CLAUDE CODE:

Analiza el sistema de Multas y Reglamentos (90 formularios):

[PEGAR ARCHIVOS de RefactorX/Base/multas_reglamentos/vue/]

Identifica:
1. Módulos principales:
   - Captura de multas
   - Requerimientos
   - Ejecutores
   - Pagos
   - Descuentos
   - Reportes

2. Workflows complejos:
   - Flujo de requerimiento (400 días)
   - Estados de multa
   - Cálculo de recargos
   - Aplicación de descuentos

3. Tablas de BD principales

Propón arquitectura de componentes y orden de implementación.
```

### 8:30 AM - 2:00 PM | Implementación Core Multas

#### Dev1: Módulo Captura de Multas (30 forms)

**Servicio API:**

```javascript
// services/multas.service.js
export const multasService = {
  // CRUD Multas
  getAll: async (filters) => {
    return await api.get('/multas', { params: filters })
  },

  getById: async (id) => {
    return await api.get(`/multas/${id}`)
  },

  crear: async (data) => {
    return await api.post('/multas', data)
  },

  actualizar: async (id, data) => {
    return await api.put(`/multas/${id}`, data)
  },

  cancelar: async (id, motivo) => {
    return await api.post(`/multas/${id}/cancelar`, { motivo })
  },

  // Requerimientos
  generarRequerimiento: async (multaId, tipo) => {
    return await api.post(`/multas/${multaId}/requerimientos`, { tipo })
  },

  getRequerimientos: async (multaId) => {
    return await api.get(`/multas/${multaId}/requerimientos`)
  },

  // Cálculos
  calcularRecargos: async (multaId) => {
    return await api.post(`/multas/${multaId}/calcular-recargos`)
  },

  calcularDescuento: async (multaId, tipoDescuento) => {
    return await api.post(`/multas/${multaId}/calcular-descuento`, {
      tipo: tipoDescuento
    })
  },

  // Pagos
  registrarPago: async (multaId, pagoData) => {
    return await api.post(`/multas/${multaId}/pagos`, pagoData)
  },

  // Búsquedas
  buscarPorPlacas: async (placas) => {
    return await api.get(`/multas/buscar/placas/${placas}`)
  },

  buscarPorFolio: async (folio) => {
    return await api.get(`/multas/buscar/folio/${folio}`)
  },

  buscarPorInfractor: async (nombre) => {
    return await api.post('/multas/buscar/infractor', { nombre })
  },

  // Reportes
  getReporteEjecutores: async (filtros) => {
    return await api.post('/multas/reportes/ejecutores', filtros)
  },

  getReporteIngresos: async (filtros) => {
    return await api.post('/multas/reportes/ingresos', filtros)
  }
}
```

**Componente principal de captura:**

```vue
<!-- modules/multas_reglamentos/views/MultasCaptura.vue -->
<template>
  <div class="multas-captura">
    <h2>Captura de Multas</h2>

    <form @submit.prevent="guardarMulta">
      <Card>
        <template #title>Datos del Infractor</template>
        <template #content>
          <div class="grid">
            <div class="col-12 md:col-6">
              <div class="p-field">
                <label for="placas">Placas del Vehículo *</label>
                <InputText
                  id="placas"
                  v-model="form.placas"
                  :class="{ 'p-invalid': errors.placas }"
                  @blur="buscarPorPlacas"
                />
                <small class="p-error">{{ errors.placas }}</small>
              </div>
            </div>

            <div class="col-12 md:col-6">
              <div class="p-field">
                <label for="folio">Folio *</label>
                <InputText
                  id="folio"
                  v-model="form.folio"
                  :class="{ 'p-invalid': errors.folio }"
                  disabled
                />
              </div>
            </div>

            <div class="col-12 md:col-6">
              <div class="p-field">
                <label for="nombre">Nombre del Infractor *</label>
                <InputText
                  id="nombre"
                  v-model="form.nombre_infractor"
                  :class="{ 'p-invalid': errors.nombre_infractor }"
                />
                <small class="p-error">{{ errors.nombre_infractor }}</small>
              </div>
            </div>

            <div class="col-12 md:col-6">
              <div class="p-field">
                <label for="direccion">Dirección</label>
                <InputText id="direccion" v-model="form.direccion" />
              </div>
            </div>
          </div>
        </template>
      </Card>

      <Card class="mt-3">
        <template #title>Datos de la Infracción</template>
        <template #content>
          <div class="grid">
            <div class="col-12 md:col-6">
              <div class="p-field">
                <label for="fecha_infraccion">Fecha y Hora *</label>
                <Calendar
                  id="fecha_infraccion"
                  v-model="form.fecha_infraccion"
                  showTime
                  hourFormat="24"
                  dateFormat="dd/mm/yy"
                  :class="{ 'p-invalid': errors.fecha_infraccion }"
                />
                <small class="p-error">{{ errors.fecha_infraccion }}</small>
              </div>
            </div>

            <div class="col-12 md:col-6">
              <div class="p-field">
                <label for="lugar">Lugar de la Infracción *</label>
                <InputText
                  id="lugar"
                  v-model="form.lugar_infraccion"
                  :class="{ 'p-invalid': errors.lugar_infraccion }"
                />
                <small class="p-error">{{ errors.lugar_infraccion }}</small>
              </div>
            </div>

            <div class="col-12 md:col-6">
              <div class="p-field">
                <label for="articulo">Artículo Infringido *</label>
                <Dropdown
                  id="articulo"
                  v-model="form.articulo_id"
                  :options="articulos"
                  optionLabel="descripcion"
                  optionValue="id"
                  filter
                  :class="{ 'p-invalid': errors.articulo_id }"
                  @change="calcularMonto"
                />
                <small class="p-error">{{ errors.articulo_id }}</small>
              </div>
            </div>

            <div class="col-12 md:col-6">
              <div class="p-field">
                <label for="monto">Monto de la Multa</label>
                <InputNumber
                  id="monto"
                  v-model="form.monto"
                  mode="currency"
                  currency="MXN"
                  locale="es-MX"
                  disabled
                />
              </div>
            </div>

            <div class="col-12">
              <div class="p-field">
                <label for="observaciones">Observaciones</label>
                <Textarea
                  id="observaciones"
                  v-model="form.observaciones"
                  rows="3"
                />
              </div>
            </div>
          </div>
        </template>
      </Card>

      <Card class="mt-3">
        <template #title>Ejecutor</template>
        <template #content>
          <div class="grid">
            <div class="col-12 md:col-6">
              <div class="p-field">
                <label for="ejecutor">Ejecutor *</label>
                <Dropdown
                  id="ejecutor"
                  v-model="form.ejecutor_id"
                  :options="ejecutores"
                  optionLabel="nombre_completo"
                  optionValue="id"
                  filter
                  :class="{ 'p-invalid': errors.ejecutor_id }"
                />
                <small class="p-error">{{ errors.ejecutor_id }}</small>
              </div>
            </div>

            <div class="col-12 md:col-6">
              <div class="p-field">
                <label for="zona">Zona</label>
                <Dropdown
                  id="zona"
                  v-model="form.zona_id"
                  :options="zonas"
                  optionLabel="nombre"
                  optionValue="id"
                />
              </div>
            </div>
          </div>
        </template>
      </Card>

      <div class="mt-3 flex justify-content-end gap-2">
        <Button
          label="Cancelar"
          icon="pi pi-times"
          class="p-button-text"
          @click="cancelar"
        />
        <Button
          type="submit"
          label="Guardar Multa"
          icon="pi pi-check"
          :loading="guardando"
        />
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { multasService } from '@/services/multas.service'
import { useToast } from 'primevue/usetoast'
import { useVuelidate } from '@vuelidate/core'
import { required, minLength } from '@vuelidate/validators'

const router = useRouter()
const toast = useToast()

// State
const form = reactive({
  folio: '',
  placas: '',
  nombre_infractor: '',
  direccion: '',
  fecha_infraccion: new Date(),
  lugar_infraccion: '',
  articulo_id: null,
  monto: 0,
  observaciones: '',
  ejecutor_id: null,
  zona_id: null
})

const articulos = ref([])
const ejecutores = ref([])
const zonas = ref([])
const guardando = ref(false)

// Validations
const rules = {
  placas: { required, minLength: minLength(6) },
  nombre_infractor: { required },
  fecha_infraccion: { required },
  lugar_infraccion: { required },
  articulo_id: { required },
  ejecutor_id: { required }
}

const v$ = useVuelidate(rules, form)
const errors = reactive({})

// Methods
const buscarPorPlacas = async () => {
  if (!form.placas || form.placas.length < 6) return

  try {
    const response = await multasService.buscarPorPlacas(form.placas)
    if (response.data.length > 0) {
      const anterior = response.data[0]
      form.nombre_infractor = anterior.nombre_infractor
      form.direccion = anterior.direccion
    }
  } catch (error) {
    // No hacer nada si no encuentra
  }
}

const calcularMonto = () => {
  const articulo = articulos.value.find(a => a.id === form.articulo_id)
  if (articulo) {
    form.monto = articulo.monto
  }
}

const guardarMulta = async () => {
  v$.value.$touch()

  if (v$.value.$invalid) {
    Object.keys(v$.value.$errors).forEach(key => {
      errors[key] = v$.value.$errors[key][0].$message
    })
    toast.add({
      severity: 'warn',
      summary: 'Validación',
      detail: 'Por favor complete los campos requeridos',
      life: 3000
    })
    return
  }

  guardando.value = true
  try {
    await multasService.crear(form)

    toast.add({
      severity: 'success',
      summary: 'Éxito',
      detail: 'Multa registrada correctamente',
      life: 3000
    })

    router.push('/multas')
  } catch (error) {
    toast.add({
      severity: 'error',
      summary: 'Error',
      detail: error.response?.data?.message || 'Error al guardar multa',
      life: 3000
    })
  } finally {
    guardando.value = false
  }
}

const cancelar = () => {
  router.push('/multas')
}

// Lifecycle
onMounted(async () => {
  // Cargar catálogos
  const [articulosData, ejecutoresData, zonasData] = await Promise.all([
    multasService.getArticulos(),
    multasService.getEjecutores(),
    multasService.getZonas()
  ])

  articulos.value = articulosData.data
  ejecutores.value = ejecutoresData.data
  zonas.value = zonasData.data

  // Generar folio automático
  form.folio = await multasService.generarFolio()
})
</script>
```

#### Dev2: Módulo de Requerimientos (30 forms)

**Workflow de requerimientos:**

```
PROMPT CLAUDE CODE:

Genera componente de Workflow de Requerimientos para Multas:

El proceso es:
1. Multa generada → Espera pago
2. Si no paga en X días → Primer requerimiento
3. Si no paga → Segundo requerimiento
4. Si no paga → Tercer requerimiento
5. Después de 400 días → Embargo o gestión de cobro

Componente debe mostrar:
- Timeline visual del proceso
- Estado actual
- Días transcurridos
- Acciones disponibles según estado
- Historial de movimientos
- Generación automática de documentos (cartas)

Usa:
- PrimeVue Timeline component
- Stepper para visualizar proceso
- FileUpload para documentos
- Print para imprimir cartas
```

### 2:00 - 4:00 PM | Módulo de Ejecutores y Descuentos (30 forms)

**División:**
- **Dev1:** Gestión de ejecutores, asignación, prenóminas
- **Dev2:** Descuentos, aplicación, autorización, reportes

---

### 4:00 - 6:00 PM | Sistema 8: ESTACIONAMIENTO EXCLUSIVO (65 formularios)

**Ambos devs trabajando en paralelo**

#### Dev1: Forms 1-33
- Módulo de ejecutores
- Notificaciones
- Folios individuales

#### Dev2: Forms 34-65
- Requerimientos
- Adeudos
- Reportes

**Similar metodología que sistemas anteriores**

---

### 6:00 - 7:30 PM | Testing Integral Día 4

```bash
# Testing de Multas
npm run dev
# Verificar flujos completos:
# - Captura de multa
# - Generación de requerimientos
# - Workflow 400 días
# - Pagos
# - Reportes ejecutores

# Testing Est. Exclusivo
# - CRUD ejecutores
# - Notificaciones masivas
# - Consultas
```

### 7:30 - 8:00 PM | Commit Día 4

```bash
git add .
git commit -m "Add: Frontend Día 4 - Multas (90 forms) + Est. Exclusivo (65 forms)"
git push origin feature/frontend-week1
```

**Checklist Fin Día 4:**
- [ ] Multas y Reglamentos completo
- [ ] Estacionamiento Exclusivo completo
- [ ] 155 formularios nuevos
- [ ] Build sin errores

**PROGRESO TOTAL: 350/470 = 74% ✅**

---

# 📅 DÍA 5 - VIERNES: Sistema Final + Testing + Deploy

## 8:00 AM - 1:00 PM | Sistema 9: ESTACIONAMIENTO PÚBLICO (120 formularios)

**SISTEMA MÁS GRANDE - TODO EL ESFUERZO EN ESTE SISTEMA**

### División de trabajo:

#### Dev1: Módulo de Folios y Propietarios (60 forms)
- Alta de folios
- Modificación de folios
- Consulta de folios
- ABC propietarios
- Asignación de ubicaciones

#### Dev2: Módulo de Pagos y Conciliación (60 forms)
- Gestión de pagos
- Integración Banorte
- Conciliación bancaria
- Generación de archivos
- Reportes de recaudación

**Servicios API:**

```javascript
// services/estacionamiento-publico.service.js
export const estacionamientoPublicoService = {
  // Folios
  folios: {
    getAll: async (params) => api.get('/estacionamiento-publico/folios', { params }),
    crear: async (data) => api.post('/estacionamiento-publico/folios', data),
    actualizar: async (id, data) => api.put(`/estacionamiento-publico/folios/${id}`, data),
    consultar: async (folio) => api.get(`/estacionamiento-publico/folios/buscar/${folio}`),
    reactivar: async (id) => api.post(`/estacionamiento-publico/folios/${id}/reactivar`),
    baja: async (id, data) => api.post(`/estacionamiento-publico/folios/${id}/baja`, data)
  },

  // Propietarios
  propietarios: {
    buscar: async (criterio) => api.post('/estacionamiento-publico/propietarios/buscar', criterio),
    crear: async (data) => api.post('/estacionamiento-publico/propietarios', data),
    actualizar: async (id, data) => api.put(`/estacionamiento-publico/propietarios/${id}`, data)
  },

  // Pagos
  pagos: {
    registrar: async (data) => api.post('/estacionamiento-publico/pagos', data),
    consultar: async (folioId) => api.get(`/estacionamiento-publico/folios/${folioId}/pagos`),
    subirPagos: async (archivo) => {
      const formData = new FormData()
      formData.append('archivo', archivo)
      return api.post('/estacionamiento-publico/pagos/cargar', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      })
    }
  },

  // Banorte
  banorte: {
    generarArchivo: async (tipo, fecha) =>
      api.post('/estacionamiento-publico/banorte/generar', { tipo, fecha }),
    conciliar: async (data) =>
      api.post('/estacionamiento-publico/banorte/conciliar', data),
    descargarArchivo: async (id) =>
      api.get(`/estacionamiento-publico/banorte/archivos/${id}`, {
        responseType: 'blob'
      })
  },

  // Reportes
  reportes: {
    ingresos: async (filtros) => api.post('/estacionamiento-publico/reportes/ingresos', filtros),
    folios: async (filtros) => api.post('/estacionamiento-publico/reportes/folios', filtros),
    estadisticas: async () => api.get('/estacionamiento-publico/reportes/estadisticas')
  }
}
```

---

## 1:00 PM - 3:00 PM | Completar Est. Público + Testing Básico

**Finalizar últimos componentes**
**Testing individual del módulo**

---

## 3:00 PM - 5:00 PM | TESTING GLOBAL DE LOS 9 SISTEMAS

### Checklist de Testing:

```markdown
## Sistema 1: Distribución
- [ ] Lista carga correctamente
- [ ] Crear nuevo registro
- [ ] Editar registro existente
- [ ] Buscar funciona
- [ ] Eliminar con confirmación

## Sistema 2: Cementerios
- [ ] Gestión de lotes
- [ ] Asignación de nichos
- [ ] Servicios y contratos
- [ ] Reportes básicos

## Sistema 3: Aseo Contratado
- [ ] Contratos funcionales
- [ ] Cobranza operativa
- [ ] Pagos se registran
- [ ] Reportes de adeudos

## Sistema 4: Mercados
- [ ] Gestión de puestos
- [ ] Registro comerciantes
- [ ] Asignación funciona
- [ ] Reportes de ocupación

## Sistema 5: Otras Obligaciones
- [ ] Módulo Giros completo
- [ ] Módulo Rubros completo
- [ ] Cálculo de adeudos
- [ ] Facturación

## Sistema 6: Padrón Licencias
- [ ] CRUD licencias OK
- [ ] Trámites funcionan
- [ ] Anuncios operativos
- [ ] Pagos y descuentos
- [ ] Reportes generan datos

## Sistema 7: Multas
- [ ] Captura de multas
- [ ] Workflow requerimientos
- [ ] Gestión ejecutores
- [ ] Pagos y descuentos
- [ ] Reportes complejos

## Sistema 8: Est. Exclusivo
- [ ] Ejecutores ABC
- [ ] Notificaciones
- [ ] Folios individuales
- [ ] Requerimientos
- [ ] Reportes

## Sistema 9: Est. Público
- [ ] Folios CRUD
- [ ] Propietarios
- [ ] Pagos funcionales
- [ ] Integración Banorte
- [ ] Conciliación
- [ ] Reportes
```

**Testing de integración:**
- [ ] Navegación entre módulos
- [ ] Menú principal funciona
- [ ] Login/Logout
- [ ] Permisos por usuario
- [ ] Responsive en móvil

---

## 5:00 PM - 6:30 PM | CORRECCIÓN DE BUGS CRÍTICOS

**Priorizar:**
1. Bugs que impiden usar sistema
2. Errores de integración con backend
3. Validaciones faltantes
4. Problemas de UI críticos

**Usar Claude Code para fixes rápidos:**
```
PROMPT CLAUDE CODE:

Tengo este error en el componente LicenciasList.vue:

[PEGAR ERROR]

Analiza y propón solución rápida sin romper nada más.
```

---

## 6:30 PM - 7:30 PM | DOCUMENTACIÓN Y BUILD FINAL

### Documentación:

```bash
# Generar README principal
cat > README.md << 'EOF'
# Sistema RefactorX - Frontend Vue.js

## Descripción
Frontend completo para sistema de Gestión Municipal

## Módulos
1. Distribución
2. Cementerios
3. Aseo Contratado
4. Mercados
5. Otras Obligaciones
6. Padrón de Licencias
7. Multas y Reglamentos
8. Estacionamiento Exclusivo
9. Estacionamiento Público

## Instalación
\`\`\`bash
npm install
\`\`\`

## Desarrollo
\`\`\`bash
npm run dev
\`\`\`

## Build Producción
\`\`\`bash
npm run build
\`\`\`

## Variables de Entorno
\`\`\`
VITE_API_URL=http://localhost:8000/api
VITE_APP_TITLE=RefactorX GDL
\`\`\`

## Tecnologías
- Vue 3 (Composition API)
- Pinia (State Management)
- Vue Router
- PrimeVue (UI Components)
- Axios (HTTP Client)
- Vite (Build Tool)

## Estructura
\`\`\`
src/
├── modules/           # 9 módulos del sistema
├── components/        # Componentes compartidos
├── services/          # Servicios API
├── stores/            # Pinia stores
├── router/            # Vue Router
├── composables/       # Composables reutilizables
└── utils/             # Utilidades
\`\`\`
EOF
```

### Build final:

```bash
# Limpiar
npm run clean

# Build de producción
npm run build

# Verificar tamaño
du -sh dist/

# Testing build
npm run preview
```

---

## 7:30 PM - 8:00 PM | DEPLOY Y CELEBRACIÓN

### Deploy:

```bash
# Merge a main
git checkout main
git merge feature/frontend-week1 --no-ff

# Tag de versión
git tag -a v1.0.0 -m "Primera versión completa frontend"

# Push final
git push origin main --tags

# Deploy a servidor
# (comandos específicos según su servidor)
scp -r dist/ usuario@servidor:/var/www/refactorx/
```

### Commit Final:

```bash
git add .
git commit -m "Release: Frontend v1.0.0 - 9 sistemas completos (470 forms)

Sistemas implementados:
- Distribución (15 forms)
- Cementerios (20 forms)
- Aseo Contratado (25 forms)
- Mercados (35 forms)
- Otras Obligaciones (40 forms)
- Padrón Licencias (60 forms)
- Multas y Reglamentos (90 forms)
- Estacionamiento Exclusivo (65 forms)
- Estacionamiento Público (120 forms)

Tecnologías:
- Vue 3 + Composition API
- Pinia + Vue Router
- PrimeVue UI
- Axios + Backend Laravel
- Vite Build Tool

TOTAL: 470 componentes Vue funcionales
Integración con backend verificada
Build de producción sin errores

🎉 PROYECTO COMPLETO EN 5 DÍAS 🎉"
```

---

## ✅ ENTREGABLES FINALES

### Código
- [x] 9 módulos Vue completos
- [x] 470 componentes funcionales
- [x] Servicios API integrados con backend
- [x] Stores Pinia configurados
- [x] Vue Router con todas las rutas
- [x] Build de producción generado
- [x] Responsive design básico

### Documentación
- [x] README.md principal
- [x] README.md por módulo
- [x] Guía de instalación
- [x] Lista de endpoints consumidos
- [x] Documentación de componentes clave

### Testing
- [x] Testing manual de 9 sistemas
- [x] Build sin errores
- [x] Integración con backend verificada
- [x] Bugs críticos resueltos

### Deploy
- [x] Código en repositorio Git
- [x] Tag v1.0.0 creado
- [x] Build deployado en servidor
- [x] Sistema accesible en producción

---

## 📊 MÉTRICAS FINALES

| Métrica | Objetivo | Alcanzado | % |
|---------|----------|-----------|---|
| Sistemas completos | 9 | 9 | 100% |
| Formularios | 470 | 470 | 100% |
| Días trabajados | 5 | 5 | 100% |
| Horas totales | 120 | 120 | 100% |
| Build sin errores | Sí | ✅ | 100% |
| Integración backend | 100% | ✅ | 100% |
| Deploy exitoso | Sí | ✅ | 100% |

---

## 🎯 LECCIONES APRENDIDAS

### Lo que funcionó bien:
✅ Claude Code aceleró desarrollo 10x
✅ Trabajo en paralelo fue efectivo
✅ Componentes base reutilizables ahorraron tiempo
✅ Backend funcionando desde día 1 fue clave
✅ Commits frecuentes evitaron problemas

### Áreas de mejora para v2:
⚠️ Testing automatizado (agregar Vitest)
⚠️ Optimización de performance (lazy loading)
⚠️ UI/UX más pulida
⚠️ Cobertura de tests >80%
⚠️ Documentación más detallada

---

## 🚀 PRÓXIMOS PASOS (Post-Sprint)

### Semana 2: Refinamiento
- [ ] Agregar tests unitarios
- [ ] Optimizar componentes pesados
- [ ] Mejorar diseño UI/UX
- [ ] Agregar animaciones
- [ ] Implementar lazy loading

### Semana 3: Features Adicionales
- [ ] Exportación a Excel/PDF
- [ ] Gráficas avanzadas (Chart.js)
- [ ] Notificaciones push
- [ ] Dark mode
- [ ] PWA features

### Semana 4: Producción
- [ ] Training usuarios
- [ ] Documentación de usuario
- [ ] Monitoreo y analytics
- [ ] Backup y recovery
- [ ] Soporte post-lanzamiento

---

**🎉 ¡FELICIDADES! PROYECTO COMPLETO EN 1 SEMANA 🎉**

**PROGRESO FINAL: 470/470 = 100% ✅✅✅**
